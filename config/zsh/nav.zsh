# Short directory-jump helpers for common roots.
c() {
    cd "$HOME/code/$1" || return 1
}

_c() {
    _files -W "$HOME/code" -/
}

x() {
    cd "$HOME/$1" || return 1
}

_x() {
    _files -W "$HOME" -/
}

if typeset -f compdef >/dev/null 2>&1; then
    compdef _c c
    compdef _x x
fi
