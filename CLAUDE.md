# Dotfiles

This repo deploys via `cp` (see `install.sh`), **not symlinks**. Files under `config/` are copied into `~/.config/`, and files under `dotfiles/` are copied to `$HOME` with a leading dot.

## Editing workflow

After changing any tracked file, run `./install.sh` to land it in the live tree (`~/.config/...`, `~/.gitconfig`, etc.). Without that step, your edit is invisible to the running shell, nvim, ghostty, etc. — they read the deployed copy, not the repo.

When adding a new file or directory that should ship with the dotfiles, add a `copy_file` / `copy_dir` line to `install.sh` too — otherwise it stays in the repo only.

## Drift check

`./scripts/check-drift` reports differences between the repo and the deployed tree. Some drift is expected and should not be backported:

- `config/zsh/.zshrc` — Hiive CLI re-injects a `hiive initialize` block on every interactive shell.
- `config/nvim/{lazyvim.json,.claude}` — LazyVim runtime files.
