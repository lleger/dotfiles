# Enable Worktrunk shell hooks only when installed.
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi
