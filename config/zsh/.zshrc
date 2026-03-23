# Prepend user and toolchain binaries so interactive shells resolve the right
# executables first.
export PATH=/opt/homebrew/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# Let mise inject shims and per-tool environment for this shell session.
eval "$(mise activate zsh)"

# Keep completion cache and shell history under XDG-managed directories.
autoload -U compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"

HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"

# Safe-chain Zsh initialization script
[[ -f "$HOME/.safe-chain/scripts/init-posix.sh" ]] && source "$HOME/.safe-chain/scripts/init-posix.sh"

# Older Hiive prompt/home-hook scripts exported their "loaded" sentinels, which
# causes child shells to skip initialization. Clear inherited values before
# sourcing the managed Hiive init script.
unset _HIIVE_PROMPT_LOADED _HIIVE_HOME_HOOK_LOADED

# >>> hiive initialize (v1) >>>
[[ -f "$HOME/.config/hiive/init.zsh" ]] && source "$HOME/.config/hiive/init.zsh"
# <<< hiive initialize (v1) <<<

# Enable worktrunk shell hooks only when installed.
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

# Load interactive aliases.
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# Load small directory-jump helpers.
[[ -f "$ZDOTDIR/nav.zsh" ]] && source "$ZDOTDIR/nav.zsh"

# Load Nushell helpers.
[[ -f "$ZDOTDIR/nushell.zsh" ]] && source "$ZDOTDIR/nushell.zsh"

# Load Atuin history integration before prompt-highlighting plugins.
[[ -f "$ZDOTDIR/atuin.zsh" ]] && source "$ZDOTDIR/atuin.zsh"

# Keep syntax highlighting activation isolated and last in startup order.
[[ -f "$ZDOTDIR/patina.zsh" ]] && source "$ZDOTDIR/patina.zsh"
