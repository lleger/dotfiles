# Convenience wrappers for opting into Nushell without changing the login shell.
nux() {
    command nu "$@"
}

nu-clean() {
    env -i \
        HOME="$HOME" \
        USER="${USER:-logan}" \
        LOGNAME="${LOGNAME:-$USER}" \
        PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
        TERM="${TERM:-xterm-256color}" \
        XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" \
        /opt/homebrew/bin/nu "$@"
}
