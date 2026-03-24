# Interactive aliases that should stay separate from the main startup flow.
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto'
    alias ll='eza --icons=auto -la --git'
    alias lt='eza --icons=auto --tree --level=2'
fi

alias pcat='command cat'

if command -v zellij >/dev/null 2>&1; then
    alias zj='zellij attach -c'
    alias za='zellij -l ai'
fi
