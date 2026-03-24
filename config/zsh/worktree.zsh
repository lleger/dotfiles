# Thin interactive wrappers around the wt CLI.
w() {
    target=$(wt pick "$@") || return 1
    cd "$target" || return 1
}

wn() {
    [ $# -eq 1 ] || {
        printf 'usage: wn <name>\n' >&2
        return 2
    }

    target=$(wt new "$1") || return 1
    cd "$target" || return 1
}

wm() {
    target=$(wt main) || return 1
    cd "$target" || return 1
}
