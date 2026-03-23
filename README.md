# Laptop Setup

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

## Install

Apply the managed files with:

```sh
./install.sh
```

Then restart the shell:

```sh
exec zsh
```

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
