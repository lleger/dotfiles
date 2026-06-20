# Dotfiles

This repo is the current baseline for my local shell, terminal, editor, and
agent tooling. It is intentionally centered around an XDG-style Zsh layout,
Neovim, Zellij, Atuin, Television, Mise, OpenCode, and zsh-patina.

## Layout

Home-directory shims:

- `~/.gitconfig`
- `~/.gitignore`
- `~/.hushlogin`
- `~/.psqlrc`
- `~/.zshenv`

XDG-managed config:

- `~/.config/atuin/config.toml`
- `~/.config/mise/config.toml`
- `~/.config/nvim`
- `~/.config/opencode/opencode.json`
- `~/.config/psql/psqlrc`
- `~/.config/television/config.toml`
- `~/.config/zellij/config.kdl`
- `~/.config/zsh/.zshenv`
- `~/.config/zsh/.zshrc`
- `~/.config/zsh/*.zsh`
- `~/.config/zsh-patina/config.toml`

## Bootstrap Packages

`mise.toml` contains the apps and CLI tools this setup expects, including:

- `1password`, `1password-cli`
- `ghostty`
- `postgres-app`
- `zed`
- `awscli`
- `atuin`
- `bat`
- `docker`
- `eza`
- `fzf`
- `gh`
- `git`
- `git-delta`
- `jq`
- `lazygit`
- `mise`
- `neovim`
- `opencode`
- `ripgrep`
- `television`
- `zellij`
- `zsh-patina`

Install them with the full bootstrap:

```sh
mise bootstrap --yes
```

## Validation

Run the repo checks with:

```sh
mise run check
```

Run just the `wt` tests with:

```sh
mise run test
```

This validates:

- `mise.toml`
- `bin/wt`
- the managed zsh files
- the managed Zellij config

## Fresh Laptop

Install Homebrew and Mise first, then from this repo run:

```sh
brew install mise
mise bootstrap --yes
exec zsh
```

After installing, finish the auth and app-specific setup that cannot be safely
stored in this repo:

- Sign in to 1Password and enable SSH agent/signing.
- Create or restore `~/.ssh/allowed_signers` for Git SSH signing.
- Run `gh auth login`.
- Run `atuin login` and `atuin sync` if restoring shell history.
- Sign in to Claude Code and OpenCode as needed.
- Add machine-specific shell config to `~/.config/zsh/local.zsh`.
- Add machine-specific Git config to `~/.gitconfig.local`.

Then validate the install:

```sh
mise run check
./scripts/check-drift
```

On a fresh machine, open Neovim once after install so LazyVim can install the
managed plugins:

```sh
nvim
```

## Install Only

Apply the managed files with:

```sh
mise dotfiles apply --yes
```

Then restart the shell:

```sh
exec zsh
```

## Git

The managed Git config includes a few workflow aliases:

- `git st`
- `git up`
- `git sw`
- `git main`
- `git lg`
- `git last`
- `git undo`

`git sw` uses `fzf` to switch local branches sorted by recent activity, with a
preview of recent commits.

## Worktrees

`wt` is a small local Git worktree helper installed to `~/.local/bin/wt`.

Current commands:

- `wt list`
- `wt cd <name>`
- `wt new <name>`
- `wt pick`
- `wt main`
- `wt rm <name>`
- `wt rm --path <path>`

Interactive zsh wrappers:

- `w` picks a worktree and `cd`s into it
- `wn <name>` creates a worktree and `cd`s into it
- `wm` jumps back to the main checkout

In interactive zsh, `wt cd <name>` jumps to an existing worktree, `wt new
<name>` drops you into the new worktree, and `wt rm <name>` hops back to the
main checkout first if you remove the worktree you are currently inside.

Managed worktrees are created relative to the current repo's parent directory:

- `~/code/cli` -> `~/code/wt/cli/<branch>`
- `~/work/server` -> `~/work/wt/server/<branch>`

Existing worktrees created by other tools still show up in `wt list` and
`wt pick`.

Completion menus for `wt cd`, `wt path`, and `wt rm` also include the latest
commit context for each branch.

## Neovim

The managed Neovim config is the official LazyVim starter layout under
`~/.config/nvim`.

This means:

- LazyVim provides the core editing experience and plugin defaults
- `lazy.nvim` is still the underlying plugin manager
- the repo keeps a committed `lazy-lock.json` for plugin version stability

This first pass is intentionally close to the starter:

- no custom plugin overrides yet
- no extra language packs yet
- no local tweaks beyond the starter structure

After the first install, a useful sanity check is:

```vim
:LazyHealth
```

Source:
- https://www.lazyvim.org/
- https://www.lazyvim.org/installation

## Zellij

The default Zellij config includes:

- `default_shell "/bin/zsh"`
- the built-in `tokyo-night` theme
- session serialization
- Neovim as the scrollback editor

Useful shell aliases:

- `zj` attaches or creates a Zellij session

## Agent Tools

Claude Code config is managed under `~/.claude`, but machine-specific skills,
plugins, MCP servers, and telemetry hooks are intentionally not included.

OpenCode config is managed under `~/.config/opencode/opencode.json`. The repo
keeps this generic: no machine-specific MCP servers and no local telemetry plugin.

## Notes

- `~/.zshenv` sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh`, so the real interactive
  shell config lives under `~/.config/zsh`.
- `PSQLRC` is set to `~/.config/psql/psqlrc`, while `~/.psqlrc` remains as a
  compatibility shim.
- `~/.config/zsh/local.zsh` is sourced when present and is the right place for
  local machine-specific shell setup.
- `~/.gitconfig.local` is included when present and is the right place for
  local Git overrides.
- The shell config assumes some optional tools may be absent and guards those
  integrations accordingly.
- Some machine-specific integrations are intentionally not managed here.
- Review `dotfiles/gitconfig` before applying it on a different machine or
  account, because it includes signing and credential configuration.
