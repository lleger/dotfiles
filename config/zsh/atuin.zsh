# Atuin hooks shell history and keybindings for interactive history search.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
