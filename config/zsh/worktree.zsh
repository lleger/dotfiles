# Thin interactive wrappers around the wt CLI.
wt() {
    case "${1-}" in
        new)
            shift
            target=$(command wt new "$@") || return 1
            cd "$target" || return 1
            ;;
        *)
            command wt "$@"
            ;;
    esac
}

w() {
    target=$(command wt pick "$@") || return 1
    cd "$target" || return 1
}

wn() {
    [ $# -eq 1 ] || {
        printf 'usage: wn <name>\n' >&2
        return 2
    }

    target=$(command wt new "$1") || return 1
    cd "$target" || return 1
}

wm() {
    target=$(command wt main) || return 1
    cd "$target" || return 1
}
