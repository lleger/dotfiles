# Worktree Tool V1

## Goal

Build a small, fast personal worktree tool that is simpler than Worktrunk and
fits the existing shell-first setup.

The tool should optimize for:

- creating a new worktree quickly
- jumping between existing worktrees quickly
- keeping paths predictable
- staying easy to inspect and debug
- working cleanly with worktrees created by other tools

The tool should not try to model GitHub, PRs, stacked branches, or branch
metadata.

## Design Direction

V1 should be a small standalone CLI plus thin zsh wrappers.

- Core executable: `wt`
- Core implementation: POSIX `sh`
- Shell integration: zsh functions for `cd` and completion
- Install target: `~/.local/bin/wt`

This split keeps the core logic shell-agnostic while allowing interactive zsh
helpers to handle directory changes.

## Why Shell First

Shell is the right starting point because the core operations are already Git
commands:

- `git rev-parse --show-toplevel`
- `git worktree list --porcelain`
- `git worktree add`
- `git worktree remove`
- `git branch`

Lua does not buy much here unless this becomes a Neovim-specific tool.
Go or Rust could make sense later if the tool grows into a richer CLI or TUI,
but that is not needed for V1.

## Repository Layout

Planned repo additions:

- `bin/wt`
- `config/zsh/worktree.zsh`

Planned install update:

- copy `bin/wt` to `~/.local/bin/wt`
- source `worktree.zsh` from `.zshrc`

## Worktree Placement

V1 should not assume every worktree was created by `wt`.

The tool should discover all worktrees that Git knows about for the current
repo, regardless of where they live or which tool created them.

When `wt` creates a new worktree, it should place it relative to the repo's
existing parent directory.

Rule:

```text
<repo-parent>/wt/<repo>/<branch>
```

Examples:

```text
~/code/cli
~/code/wt/cli/feat-fast-worktrees

~/hiive/server
~/hiive/wt/server/fix-buyer-flow
```

Why this layout:

- keeps worktrees near the repo they belong to
- works for both `~/code` and `~/hiive`
- avoids forcing one global worktree root
- still gives `wt`-managed worktrees a predictable location

Branch names containing `/` should map directly to nested directories.

## Mixed-Origin Support

`wt` should treat Git as the source of truth for existing worktrees.

That means:

- `list` should show all worktrees for the repo
- `pick` should allow selecting all worktrees for the repo
- `new` should create only in the managed `wt/` location
- `rm` should support both managed names and explicit paths

This keeps the tool compatible with worktrees created by Claude, Codex,
Worktrunk, or manual Git commands.

## Command Surface

V1 should stay small.

### `wt list`

List worktrees for the current repo.

Expected behavior:

- derive the current repo root
- show known worktrees for that repo
- print path and branch in a readable format
- highlight the current worktree if practical

This command should favor fast human-readable output over a rich table UI.

### `wt new <name>`

Create a new branch worktree for the current repo and print the path.

Expected behavior:

- resolve the main repo name from the current checkout
- create the target path under `<repo-parent>/wt/<repo>/<name>`
- create the branch if needed
- add the worktree
- print the resulting path

Open question:

- should `new` always create a branch from the current branch, or always from a
  default branch such as `main`

Decision:

- create from the current `HEAD`

That matches the least-surprising shell behavior and avoids adding default-branch
policy too early.

### `wt pick`

Interactively select an existing worktree and print its path.

Expected behavior:

- use `fzf` when available
- include branch name and path in the picker
- print only the selected path to stdout

This makes it easy for shell wrappers to `cd` into the selected worktree.

If `fzf` is missing, this command should degrade gracefully with a plain-text
selection flow instead of failing outright.

### `wt main`

Print the main checkout path for the current repo.

Expected behavior:

- detect the primary checkout for the repo
- print that path only

This is mainly for jump helpers.

### `wt rm <name>`

Remove a worktree by name.

Expected behavior:

- resolve managed names under `<repo-parent>/wt/<repo>/<name>`
- remove the worktree
- fail clearly if the path does not exist

V1 should not delete the branch automatically unless that behavior becomes
clearly useful.

### `wt rm --path <path>`

Remove a worktree by explicit path.

Expected behavior:

- remove any valid worktree for the current repo, regardless of where it lives
- avoid assuming the path was created by `wt`

This is the escape hatch for mixed-origin worktrees.

Force removal should be supported by passing through to Git, for example via a
`--force` flag.

## Zsh Wrappers

The CLI should stay simple and shell-neutral. Interactive navigation belongs in
zsh wrappers.

Planned helpers:

### `w`

Pick a worktree and `cd` into it.

Concept:

```zsh
cd "$(wt pick)"
```

### `wn <name>`

Create a new worktree and `cd` into it.

Concept:

```zsh
cd "$(wt new "$1")"
```

### `wm`

Jump back to the main checkout for the current repo.

Concept:

```zsh
cd "$(wt main)"
```

## Performance Principles

V1 should stay fast by being conservative:

- parse `git worktree list --porcelain` once per command
- avoid repeated `git` calls when one will do
- avoid shell-heavy pipelines when simple loops are enough
- avoid network access entirely
- avoid caches or local state files

The tool should derive state from Git instead of maintaining its own metadata.

## Non-Goals

Not in V1:

- GitHub or PR integration
- stacked branch workflows
- automatic branch deletion rules
- session management
- Zellij layout automation
- a full-screen TUI
- repo-specific config files

## Open Questions

## Settled V1 Decisions

The following decisions are settled for V1:

1. `wt new <name>` should create from the current `HEAD`.
2. `wt list` should operate on the current repo only.
3. `wt rm` should defer removal rules to Git and support force removal.
4. `wt pick` should degrade gracefully if `fzf` is missing.

## Recommended V1 Scope

If the goal is to validate the workflow quickly, the first implementation
should include exactly:

- `wt list`
- `wt new`
- `wt pick`
- `wt main`
- `wt rm`
- `w`, `wn`, and `wm` zsh wrappers

That is enough to test whether this is materially better than Worktrunk without
committing to a bigger system.
