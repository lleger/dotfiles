---
name: review-pr-comments
description: Review unresolved PR comments, address them (fix, push back, or ask), then reply inline. Interactive by default — pass `--auto` to run unattended. Optional args set the PR or reviewer filter.
user-invocable: true
argument-hint: "[--auto] [<pr_number|url>] [copilot | codex | @username]"
allowed-tools:
  - Bash(gh pr view *)
  - Bash(*review-pr-comments/scripts/fetch-review-threads.sh *)
  - Bash(*review-pr-comments/scripts/fetch-issue-comments.sh *)
  - Bash(*review-pr-comments/scripts/post-replies.sh *)
  - Bash(git status*)
  - Bash(git diff*)
  - Bash(git log*)
  - Bash(git add *)
  - Bash(git commit *)
  - Bash(git push*)
  - Read
  - Edit
---

# Review PR Comments

You are reviewing unresolved review threads on a pull request. Your goal is to address each thread thoughtfully — either by fixing the code, pushing back with a clear rationale, or escalating to the user when you're unsure.

## Modes

The skill runs in one of two modes:

- **Interactive (default)**: ask the user before every action. For each thread, present your proposed approach (fix / push back / what you'll change) and wait for approval before editing, committing, pushing, or replying.
- **Autonomous (`--auto`)**: process threads yourself without per-action approval. Still call `AskUserQuestion` whenever you have meaningful uncertainty about the right approach for a specific thread. High-confidence fixes, push-backs, and replies happen without interruption.

### When to use AskUserQuestion

`AskUserQuestion` applies in **both modes**. In autonomous mode it's your only escalation channel; in interactive mode use it on top of the per-action approval whenever the choice itself (not just whether to act) is unclear. It's a much better UX than guessing — use it liberally when you're not confident, not as a last resort. Concrete triggers:

- The comment requests a behavior change with multiple plausible interpretations.
- The fix would touch code outside the PR's scope, or change public API/types.
- You disagree with the reviewer but the disagreement is non-obvious or could affect another team.
- The comment is ambiguous, terse ("?", "really?"), or context-light enough that you can't infer intent.
- **The reviewer phrased it as a question to you** ("what do you actually need?", "why this and not that?"). Don't infer the answer and act — ask back, even if you think you know.
- Two reviewers' comments conflict and you'd have to choose between them.

Frame the question with the comment quoted, the options you're considering, and what you'd do by default. Multi-select where it makes sense.

## Argument parsing

Parse arguments before fetching anything. They can appear in any order:

- **Numeric (`123`) or PR URL** → use that PR instead of the current branch's PR. Match `^\d+$` or `^https?://github\.com/[^/]+/[^/]+/pull/\d+(/.*)?$`.
- **`--auto`** → switch to autonomous mode (skip per-action approval).
- **Reviewer filter** (one of):
  - `copilot` → reviewer login `copilot-pull-request-reviewer[bot]`
  - `codex` → reviewer login matches `chatgpt-codex-connector` (or whatever Codex login the repo uses; if unsure, list unique reviewer logins from the fetched comments and pick the match).
  - `@username` or `username` → exact match on the reviewer login, case-insensitive. Strip a leading `@`.

**Field-name reminder:** review-thread comments (from the GraphQL fetch) expose `author.login`. Issue-level comments (from the REST fetch) expose `user.login`. Apply the filter against whichever field the comment's source uses — don't blindly use one or the other.

If a non-matching argument arrives, ask the user before falling back to "process all" — silent fallback hides bugs.

## Step 1: Identify the PR

Resolve the target PR. Include `author` in the JSON fields — you need the author login later to detect author-replies:

```bash
gh pr view --json number,url,headRefName,baseRefName,author
```

If a PR number/URL was passed as an argument, use `gh pr view <n_or_url> --json ...` instead.

## Step 2: Fetch comments

Use the bundled fetch scripts — one for review threads (GraphQL + pagination + `isResolved` filter) and one for issue-level comments (REST + pagination + flattening). Don't invoke `gh api` directly for either; the scripts handle the edge cases that bare `gh api` calls miss.

### Review threads (use the bundled fetch script)

The REST `pulls/{n}/comments` endpoint doesn't return thread `isResolved` state, and a single GraphQL call caps at 100 threads. The skill ships a script that handles the GraphQL query, pagination, and `isResolved` filtering in one shot:

```bash
<skill-dir>/scripts/fetch-review-threads.sh <owner> <repo> <pr_number>
```

It writes a JSON array of unresolved threads to stdout. Each thread looks like:

```jsonc
{
  "id": "PRRT_...",
  "isResolved": false,
  "isCollapsed": false,
  "comments": {
    "nodes": [
      {
        "databaseId": 3192360276,    // root comment ID — use this when replying
        "author": { "login": "..." },
        "body": "...",
        "path": "path/to/file",
        "line": 39,
        "createdAt": "..."
      },
      // ... subsequent replies in chronological order
    ]
  }
}
```

The first entry in `comments.nodes` is the root of the thread.

### Issue-level comments (use the bundled fetch script)

```bash
<skill-dir>/scripts/fetch-issue-comments.sh <owner> <repo> <pr_number>
```

Returns a flat JSON array of all issue-level comments across all pages. Wraps `gh api --paginate --slurp` and flattens internally — callers never see page boundaries.

### Handling large fetch output

These responses can be tens of KB on busy PRs. Do **not** pipe through `jq`/`head` to summarize — piping breaks the auto-approval pattern. If the harness you're running in persists large outputs to a file (Claude Code does this), read from that file with `Read`. Otherwise narrow the fetch (e.g., paginate or filter server-side) so the response stays inline-readable.

### Who to address

Address ALL unresolved threads — humans, Copilot, Codex, any other bot, and the **PR author themselves**. The PR author may leave new threads on their own PR with TODOs that need attention. Do not deprioritize based on author.

### Skip rules

#### Review threads

Only skip a thread if **either**:

- Its `isResolved == true` (the script already filters these out), OR
- The PR author has already **replied** in the thread AND the reply indicates the matter is closed (e.g., "fixed in <sha>", "won't do, here's why", a clear resolution). Do **not** skip if the author's reply says the work is still pending or asks Claude/someone to handle it (e.g., "Claude, fix this", "I'll address this in a follow-up", "TODO"). Read the reply — don't pattern-match the author login alone.

The original comment being authored by the PR author does NOT count as "already replied to."

#### Issue-level comments

Issue-level comments don't have `isResolved`. Walk the timeline in chronological order and skip a comment if a **later** comment from the PR author addresses it — typically a `p.p. Claude` reply or an explicit acknowledgment ("done", "fixed in <sha>"). Same "pending work" exception as review threads: if the author's later comment defers the work or asks for follow-up, don't skip.

Treat any comment after the most recent author resolution as fresh work.

## Step 3: Look for cross-reviewer themes

Before processing individual threads, scan all the unresolved threads and identify **themes** — patterns of feedback that surface across multiple reviewers (e.g., "two reviewers are asking for the same allowlist tightening", "humans and Codex both flagged the same API shape"). Themes carry more weight than single threads and often deserve a single, comprehensive fix rather than N small ones.

Surface the themes you found in your plan before fixing anything.

## Step 4: Group by reviewer, then decide per thread

Group unresolved threads by reviewer and read each reviewer's set together — threads within a single review are usually contextual, and a later one may soften, clarify, or contradict an earlier one.

For each thread, read the relevant code, then choose:

1. **Fix** — the thread identifies a valid issue.
2. **Push back** — the thread doesn't apply or you disagree; reply with a clear rationale.
3. **Ask user** — see "When to use AskUserQuestion" above.

In **interactive mode (default)**, present your decision per thread (with the specific change or rationale) and wait for approval before acting.

In **autonomous mode (`--auto`)**, proceed without per-thread approval — but escalate via `AskUserQuestion` whenever the triggers above apply.

## Step 5: Apply fixes

For each thread you're fixing:

- Read the relevant file(s).
- Make the fix using Edit.
- Keep fixes minimal and focused on what the thread asks for.

In **interactive mode**, commit and push after each individual fix. In **autonomous mode**, batch fixes (one commit, or split by scope).

### Pre-push verification

Before `git push`, follow the repo's documented pre-push instructions if any (typically in CLAUDE.md or a top-level README). If checks fail, fix the failures before pushing.

### Commit + push

Write a descriptive commit message that summarizes the actual changes — not a generic "address review comments":

```bash
git add <changed files>
git commit -m "fix(<scope>): <what was actually changed>"
git push
```

Examples: `fix(auth): add nil check for session token per review`, `fix(api): rename field to match spec`. If fixes span unrelated areas, multiple commits are fine.

## Step 6: Post replies in one batch

Pass the JSON array of replies as the 4th positional arg to the bundled `post-replies.sh` script — **as a single-line bash invocation**:

```bash
<skill-dir>/scripts/post-replies.sh <owner> <repo> <pr_number> '[{"type":"review","root_id":3192360276,"body":"Fixed in abc1234.\n\np.p. Claude"},{"type":"review","root_id":3197944795,"body":"Tightened the regex. Fixed in abc1234.\n\np.p. Claude"},{"type":"issue","body":"Bumped the version.\n\np.p. Claude"}]'
```

The script posts each reply as its own `gh api` POST internally, prints per-reply progress, and exits non-zero on the first failure.

### Why one line matters

Claude Code's permission allowlist is matched per-line. A multi-line bash command (heredoc, multi-line string literal, etc.) prompts for approval even when the script path is allowlisted. Keep the JSON on a single line and the whole invocation stays single-line and auto-approves.

JSON tolerates absent whitespace, so even a long array fits on one line. Reply bodies use `\n` (the JSON escape) for newlines — the `gh api` reply endpoint renders them correctly on GitHub.

### Reply types

Each entry in the JSON array is one of:

- **Review-thread reply** — `{"type": "review", "root_id": <int>, "body": "<text>"}`. The `root_id` is `thread.comments.nodes[0].databaseId` from the fetch script (GitHub's reply endpoint requires the root comment ID, not a reply's own ID).
- **Issue-level reply** — `{"type": "issue", "body": "<text>"}`.

### Quoting

Wrap the JSON in single quotes — JSON itself uses only double quotes for strings, so there's no conflict. If a reply body contains a single quote (e.g., "doesn't"), escape it inside the bash literal as `'\''`. Keep markdown, backticks, and asterisks as-is — single quotes prevent shell interpretation.

### Reply guidelines

- If you fixed something: reference the commit SHA (e.g., "Fixed in abc1234.").
- If pushing back: be respectful and give a clear reason.
- One or two sentences is usually enough.
- Do not use emojis unless the reviewer's style uses them.
- Sign every reply with `p.p. Claude` on a new line — standard *per procurationem* notation, signaling the reply was posted on the author's behalf.

## Important

- Always read the code before deciding how to address a thread.
- Never dismiss a thread without explanation.
- When in doubt, `AskUserQuestion` — don't guess.
