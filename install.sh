#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

copy_file() {
  src="$1"
  dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp "$ROOT/$src" "$dest"
}

copy_dir() {
  src="$1"
  dest="$2"
  mkdir -p "$dest"
  cp -R "$ROOT/$src/." "$dest/"
}

copy_executable() {
  src="$1"
  dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp "$ROOT/$src" "$dest"
  chmod 755 "$dest"
}

copy_file "dotfiles/gitconfig" "$HOME/.gitconfig"
copy_file "dotfiles/gitignore" "$HOME/.gitignore"
copy_file "dotfiles/hushlogin" "$HOME/.hushlogin"
copy_file "dotfiles/psqlrc" "$HOME/.psqlrc"
copy_file "dotfiles/zshenv" "$HOME/.zshenv"

mkdir -p "$HOME/.config" "$HOME/.local/state/psql"
mkdir -p "$HOME/.local/bin"

copy_dir "config/atuin" "$HOME/.config/atuin"
copy_dir "config/psql" "$HOME/.config/psql"
copy_dir "config/zellij" "$HOME/.config/zellij"
copy_dir "config/zsh" "$HOME/.config/zsh"
copy_dir "config/zsh-patina" "$HOME/.config/zsh-patina"
copy_executable "bin/wt" "$HOME/.local/bin/wt"

mkdir -p "$HOME/.claude"
copy_file "config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
copy_file "config/claude/settings.json" "$HOME/.claude/settings.json"
