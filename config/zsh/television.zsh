if command -v tv >/dev/null 2>&1; then
    eval "$(tv init zsh)"
    bindkey -r '^R'
fi
