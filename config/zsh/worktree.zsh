# Thin interactive wrappers around the wt CLI.
_wt_rm_target_path() {
    local force=0
    local path_mode=0
    local target=""

    while (( $# > 0 )); do
        case "$1" in
            --force|-f)
                force=1
                ;;
            --path)
                path_mode=1
                shift
                (( $# > 0 )) || return 2
                target=$1
                ;;
            -*)
                return 2
                ;;
            *)
                [[ -z "$target" ]] || return 2
                target=$1
                ;;
        esac
        shift
    done

    [[ -n "$target" ]] || return 2

    if (( path_mode )); then
        printf '%s\n' "$target"
    else
        command wt path "$target"
    fi
}

_wt_cd_target_path() {
    if [[ $# -eq 0 ]]; then
        return 2
    fi

    if [[ -e "$1" ]]; then
        printf '%s\n' "$1"
        return 0
    fi

    command wt path "$1"
}

_wt_worktree_names() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    git worktree list --porcelain | awk '
        /^worktree / {
            path = substr($0, 10)
            branch = ""
            next
        }

        /^branch refs\/heads\// {
            branch = substr($0, 19)
            next
        }

        /^$/ {
            if (branch != "" && system("test -d \"" path "/.git\"") != 0) {
                print branch
            }
            path = ""
            branch = ""
        }

        END {
            if (branch != "" && system("test -d \"" path "/.git\"") != 0) {
                print branch
            }
        }
    '
}

_wt_worktree_descriptions() {
    local branch sha subject

    while IFS= read -r branch; do
        [[ -n "$branch" ]] || continue
        sha=$(git log -1 --format=%h "refs/heads/$branch" 2>/dev/null) || sha=""
        subject=$(git log -1 --format=%s "refs/heads/$branch" 2>/dev/null) || subject=""
        printf '%s\t%s: (%s) %s\n' "$branch" "$branch" "${sha:-???????}" "${subject:-no commits}"
    done < <(_wt_worktree_names)
}

_wt() {
    local -a subcommands names
    local path_index
    subcommands=(
        "list:list worktrees"
        "cd:cd into worktree"
        "new:create worktree"
        "pick:pick worktree"
        "main:show main worktree path"
        "path:resolve worktree path"
        "rm:remove worktree"
    )

    if (( CURRENT == 2 )); then
        _describe -t commands "wt command" subcommands
        return
    fi

    case "${words[2]-}" in
        rm)
            local -a specs descriptions
            path_index=${words[(I)--path]}
            if (( path_index > 0 && path_index < CURRENT )); then
                _files -/
                return
            fi

            if [[ "${words[CURRENT]}" == -* ]]; then
                compadd -Q -S '' -- --force --path
                return
            fi

            specs=("${(@f)$(_wt_worktree_descriptions)}")
            if (( ${#specs[@]} )); then
                names=()
                descriptions=()
                local spec name desc
                for spec in "${specs[@]}"; do
                    name=${spec%%$'\t'*}
                    desc=${spec#*$'\t'}
                    names+=("$name")
                    descriptions+=("$desc")
                done
                compadd -Q -S '' -d descriptions -- "${names[@]}"
            else
                _message "worktree"
            fi
            return
            ;;
        path)
            local -a specs descriptions
            specs=("${(@f)$(_wt_worktree_descriptions)}")
            if (( ${#specs[@]} )); then
                names=()
                descriptions=()
                local spec name desc
                for spec in "${specs[@]}"; do
                    name=${spec%%$'\t'*}
                    desc=${spec#*$'\t'}
                    names+=("$name")
                    descriptions+=("$desc")
                done
                compadd -Q -S '' -d descriptions -- "${names[@]}"
            else
                _message "worktree"
            fi
            return
            ;;
        cd)
            local -a specs descriptions
            specs=("${(@f)$(_wt_worktree_descriptions)}")
            if (( ${#specs[@]} )); then
                names=()
                descriptions=()
                local spec name desc
                for spec in "${specs[@]}"; do
                    name=${spec%%$'\t'*}
                    desc=${spec#*$'\t'}
                    names+=("$name")
                    descriptions+=("$desc")
                done
                compadd -Q -S '' -d descriptions -- "${names[@]}"
            else
                _message "worktree"
            fi
            return
            ;;
        new)
            _message "new worktree name"
            return
            ;;
        *)
            return
            ;;
    esac
}

wt() {
    case "${1-}" in
        cd)
            shift
            target=$(_wt_cd_target_path "$@") || return 1
            cd "$target" || return 1
            ;;
        new)
            shift
            target=$(command wt new "$@") || return 1
            cd "$target" || return 1
            ;;
        rm)
            shift
            target=$(_wt_rm_target_path "$@") || return $?

            if [[ "$PWD" == "$target" || "$PWD" == "$target"/* ]]; then
                main_target=$(command wt main) || return 1
                if [[ "$main_target" != "$target" ]]; then
                    cd "$main_target" || return 1
                fi
            fi

            command wt rm "$@"
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

if typeset -f compdef >/dev/null 2>&1; then
    compdef _wt wt
fi
