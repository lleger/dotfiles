---
name: review-pr-comments
description: Review new PR comments, address them (fix code, push back, or ask user), then reply inline one by one.
user-invocable: true
---

# Review PR Comments

You are reviewing unresolved comments on a pull request. Your goal is to address each comment thoughtfully — either by fixing the code, pushing back with a clear rationale, or escalating to the user when you're unsure.

## Step 1: Identify the PR

- If you're on a branch with an open PR, find it: `gh pr view --json number,url,headRefName,baseRefName`
- If the user provided a PR number or URL, use that instead.

## Step 2: Fetch unresolved review comments

Get all review comments on the PR:

```
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate
```

Also get issue-level comments:

```
gh api repos/{owner}/{repo}/issues/{pr_number}/comments --paginate
```

Address ALL unresolved comments that haven't been replied to by the PR author — regardless of who left them. This includes comments from humans, Copilot, Codex, and any other bot or AI reviewer. Do not skip or deprioritize comments based on their author. Only skip comments that are already resolved or that the PR author has already replied to.

## Step 3: Group comments by reviewer, then address them

Before processing individual comments, group all unresolved comments by reviewer. Read all comments from a single reviewer together before deciding how to address any of them — reviews (especially from humans) are usually contextual within each other. A later comment may clarify, soften, or contradict an earlier one.

For each comment, read the relevant code context, then choose one of:

1. **Fix**: The comment identifies a valid issue — fix the code.
2. **Push back**: The comment suggests a change you disagree with or that doesn't apply — reply explaining why.
3. **Ask user**: You're unsure how to address it — present the comment and options to the user via AskUserQuestion.

## Step 4: Apply fixes

For comments you're fixing:
- Read the relevant file(s)
- Make the fix using Edit
- Keep fixes minimal and focused on what the comment asks for

After all fixes are made, stage, commit, and push. Write a descriptive commit message that summarizes the actual changes made, not a generic "address review comments":
```
git add <changed files>
git commit -m "fix(<scope>): <what was actually changed>"
git push
```

For example: `fix(auth): add nil check for session token per review` or `fix(api): rename field to match spec, add missing validation`. If fixes span unrelated areas, it's fine to make multiple commits.

## Step 5: Reply to each comment individually

Reply to each comment ONE AT A TIME using individual `gh api` calls. Do NOT batch replies into a single script or review submission.

For review comments (comments on specific lines of code), reply to each one:
```
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies -f body="<your reply>"
```

For issue-level comments, reply:
```
gh api repos/{owner}/{repo}/issues/{pr_number}/comments -f body="<your reply>"
```

IMPORTANT: Keep commands simple. Do NOT pipe through jq, redirect stderr, or append extra commands. Just the bare `gh api` call — the JSON response is sufficient. Piping or redirecting can break permission matching and cause unnecessary approval prompts.

Reply guidelines:
- If you fixed something: reference the commit SHA (e.g., "Good catch — fixed in abc1234.")
- If pushing back: be respectful and give a clear reason
- Keep replies concise — one or two sentences is usually enough
- Do not use emojis unless the reviewer's style uses them
- Sign every reply with "p.p. Claude" on a new line (this is standard notation meaning the reply was posted on someone's behalf without their direct review)
- Remember: replies are posted as the PR author (the user), not as a separate bot account. The "p.p. Claude" signature makes this transparent to reviewers.

## Important

- Process comments sequentially, one at a time
- Always read the code before deciding how to address a comment
- Never dismiss a comment without explanation
- If a comment is ambiguous, ask the user rather than guessing
