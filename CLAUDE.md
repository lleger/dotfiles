# Dotfiles

This repo deploys via `mise dotfiles apply` / `mise bootstrap` in copy mode, **not symlinks**. Files under `config/` are copied into `~/.config/`, and files under `dotfiles/` are copied to `$HOME` with a leading dot.

## Editing workflow

After changing any tracked managed file, run `mise dotfiles apply --yes` to land it in the live tree (`~/.config/...`, etc.). Without that step, your edit is invisible to the running shell, nvim, ghostty, etc. — they read the deployed copy, not the repo.

When adding a new file or directory that should ship with the dotfiles, add a `[dotfiles]` entry to `mise.toml` too — otherwise it stays in the repo only.

## Drift check

`./scripts/check-drift` reports differences between the repo and the deployed tree. Some drift is expected and should not be backported:

- `config/zsh/.zshrc` — machine-local tooling may re-inject local init blocks in deployed shells.
- `config/nvim/{lazyvim.json,.claude}` — LazyVim runtime files.
