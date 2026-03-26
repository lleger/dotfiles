---
name: retro
description: End-of-session retrospective. Reflects on the session, saves learnings to memory, and proposes tooling improvements (permissions, skills, scripts).
user-invocable: true
---

# Session Retrospective

You are running a retrospective on the current session. Your goal is to extract durable value from the work just done — things that will make future sessions faster, smoother, and more autonomous.

## Step 1: Review the session

Look back through the full conversation. Identify:

1. **Friction points**: Where did you get blocked, need multiple attempts, or require user correction? What caused it?
2. **Permission prompts**: Were there tools or commands that kept asking for permission and shouldn't have? (Safe, repeatable actions the user always approved.)
3. **Repeated patterns**: Did you do something manually multiple times that could be a script or skill?
4. **User corrections**: Did the user redirect your approach? What was the lesson — and is it specific to this session or a general preference?
5. **Frustration signals**: Scan for snark, profanity, exasperation, or terse corrections from the user. These are moments where you meaningfully failed — treat them as high-signal. What went wrong, and what should change to prevent it?
6. **Things that went well**: What approaches or decisions did the user confirm or accept without pushback? These are worth preserving too.
7. **Missing context**: Was there domain knowledge, project context, or a reference you wished you had from the start?
8. **Prompting opportunities**: Were there moments where better or earlier context from the user would have saved time? Places where ambiguity led you down the wrong path, or where upfront constraints would have focused the work?

## Step 2: Present findings

Summarize your findings to the user in a concise list, grouped into these categories:

### Memories to save
- User preferences or corrections that apply beyond this session
- Project context that isn't in the code or git history
- External references discovered during the session

### Tooling improvements
- Permissions to add to settings.json (commands that were always approved)
- New skills to create (repeated workflows that could be invoked with a slash command)
- Scripts to write (automations, helpers, or checks that came up repeatedly)
- Hooks to add (automated actions that should fire on specific events)

### Things that worked well
- Approaches or patterns to keep doing (so they don't drift)

### Feedback for the user
- Moments where earlier or clearer context would have saved time
- Ambiguous instructions that led to wrong approaches
- Information you wished you had upfront
- Suggestions for how the user could prompt differently next time

Be direct and specific here — the user wants honest feedback, not diplomacy. Frame it as "here's what would help me help you faster" not "you did something wrong."

For each item, include a one-line rationale.

## Step 3: Get user approval

Use AskUserQuestion to present the full list and ask which items to act on. Do not make any changes without approval. Present it as a checklist the user can accept, reject, or modify.

## Step 4: Execute approved changes

For each approved item:

**Memories**: Write to the memory system following the memory guidelines. Read MEMORY.md first to check for duplicates or memories that should be updated rather than created.

**Permissions**: Read settings.json, merge new permissions into the existing allow array, and save. Follow the same pattern as existing entries.

**Skills**: Create a new skill directory under `~/.claude/skills/<skill-name>/SKILL.md` with proper frontmatter. Keep the skill focused and actionable.

**Scripts**: If the script is a helper for a specific skill, put it in that skill's directory (e.g., `~/.claude/skills/<skill-name>/scripts/`). For general-purpose scripts, follow XDG conventions — write to `~/.local/bin/` and make executable. Respect `$XDG_DATA_HOME` if set.

**Hooks**: Read settings.json, merge new hooks into the existing hooks object, and save. Test the hook command with a pipe-test before writing.

## Guidelines

- Be selective. Not everything is worth persisting — only save what will genuinely help in future sessions.
- Prefer updating existing memories/skills over creating new ones.
- Don't save things that are already in CLAUDE.md, the code, or git history.
- Don't save ephemeral task details — focus on patterns and preferences.
- When in doubt about whether something is worth saving, include it in the proposal and let the user decide.
- Keep the retro itself short. This is a 2-minute reflection, not a 20-minute postmortem.
