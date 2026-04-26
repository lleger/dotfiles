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

alias ..='cd ..'

if command -v zellij >/dev/null 2>&1; then
    alias zj='zellij attach -c'
    alias za='zellij -l ai'
fi

if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

if command -v doggo >/dev/null 2>&1; then
    dig() {
        print -u2 -- "hint: \`doggo\` is installed — try it for a friendlier DNS client."
        command dig "$@"
    }
fi

if command -v fzf >/dev/null 2>&1; then
    psf() {
        ps aux | fzf --header-lines=1 --reverse
    }
    psk() {
        local pids
        pids=$(ps aux | fzf --header-lines=1 --reverse --multi --prompt='kill> ' | awk '{print $2}')
        [[ -z "$pids" ]] && return 0
        echo "$pids" | xargs kill "$@"
    }
fi
