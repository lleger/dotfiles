# zsh-patina should be initialized at the end of zsh startup so it can hook the
# final interactive command line state.
if command -v zsh-patina >/dev/null 2>&1; then
  eval "$(zsh-patina activate)"
fi
