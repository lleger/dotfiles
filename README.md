# Dotfiles

This repo is the current baseline for my local shell and terminal environment.
It is intentionally small and centered around an XDG-style Zsh layout, Neovim,
Zellij, Atuin, and zsh-patina.

## Layout

Home-directory shims:

- `~/.gitconfig`
- `~/.gitignore`
- `~/.hushlogin`
- `~/.psqlrc`
- `~/.zshenv`

XDG-managed config:

- `~/.config/atuin/config.toml`
- `~/.config/nvim`
- `~/.config/psql/psqlrc`
- `~/.config/zellij/config.kdl`
- `~/.config/zsh/.zshenv`
- `~/.config/zsh/.zshrc`
- `~/.config/zsh/*.zsh`
- `~/.config/zsh-patina/config.toml`

## Brew Bundle

The `Brewfile` contains the core CLI tools this setup expects:

- `atuin`
- `bat`
- `eza`
- `fzf`
- `gh`
- `git`
- `jq`
- `mise`
- `neovim`
- `nushell`
- `ripgrep`
- `trash`
- `zellij`
- `zsh-patina`

Install them with:

```sh
brew bundle
```

## Validation

Run the repo checks with:

```sh
mise run check
```

This validates:

- `install.sh`
- `bin/wt`
- the managed zsh files
- the managed Zellij config and layouts

## Install

Apply the managed files with:

```sh
./install.sh
```

Then restart the shell:

```sh
exec zsh
```

On a fresh machine, open Neovim once after install so `lazy.nvim` can install
the managed plugins:

```sh
nvim
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
- `wt new <name>`
- `wt pick`
- `wt main`
- `wt rm <name>`
- `wt rm --path <path>`

Interactive zsh wrappers:

- `w` picks a worktree and `cd`s into it
- `wn <name>` creates a worktree and `cd`s into it
- `wm` jumps back to the main checkout

Managed worktrees are created relative to the current repo's parent directory:

- `~/code/cli` -> `~/code/wt/cli/<branch>`
- `~/hiive/server` -> `~/hiive/wt/server/<branch>`

Existing worktrees created by other tools still show up in `wt list` and
`wt pick`.

## Neovim

The managed Neovim config is a small `lazy.nvim` setup under
`~/.config/nvim`.

Current first-pass plugins:

- `folke/tokyonight.nvim`
- `nvim-telescope/telescope.nvim`
- `nvim-treesitter/nvim-treesitter`
- `neovim/nvim-lspconfig`
- `lewis6991/gitsigns.nvim`

The config includes:

- baseline editing options and split/navigation keymaps
- Telescope pickers on `<leader>ff`, `<leader>fg`, `<leader>fb`, and `<leader>fh`
- Treesitter highlighting for the languages you are likely to touch often
- LSP wiring for common servers when they are installed on the machine
- a committed `lazy-lock.json` for plugin version stability

## Zellij

The default Zellij config includes:

- `default_shell "/bin/zsh"`
- the built-in `tokyo-night` theme
- session serialization
- Neovim as the scrollback editor

The managed layout [ai.kdl](/Users/logan/code/dotfiles/config/zellij/layouts/ai.kdl) gives you one large main pane plus a right-side `lazygit` pane.

Useful shell aliases:

- `zj` attaches or creates a Zellij session
- `za` launches Zellij with the `ai` layout

## Notes

- `~/.zshenv` sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh`, so the real interactive
  shell config lives under `~/.config/zsh`.
- `PSQLRC` is set to `~/.config/psql/psqlrc`, while `~/.psqlrc` remains as a
  compatibility shim.
- The shell config assumes some optional tools may be absent and guards those
  integrations accordingly.
- Some machine-specific integrations are intentionally not managed here.
- Review `dotfiles/gitconfig` before applying it on a different machine or
  account, because it includes signing and credential configuration.
