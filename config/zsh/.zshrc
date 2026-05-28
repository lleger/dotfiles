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

# Load interactive aliases.
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# Load small directory-jump helpers.
[[ -f "$ZDOTDIR/nav.zsh" ]] && source "$ZDOTDIR/nav.zsh"

# Load worktree helpers and navigation wrappers.
[[ -f "$ZDOTDIR/worktree.zsh" ]] && source "$ZDOTDIR/worktree.zsh"

# Load Television fuzzy-finder integration (Ctrl-T smart autocomplete).
# Sourced before Atuin so Atuin's Ctrl-R binding wins.
[[ -f "$ZDOTDIR/television.zsh" ]] && source "$ZDOTDIR/television.zsh"

# Load Atuin history integration before prompt-highlighting plugins.
[[ -f "$ZDOTDIR/atuin.zsh" ]] && source "$ZDOTDIR/atuin.zsh"

# Keep syntax highlighting activation isolated and last in startup order.
[[ -f "$ZDOTDIR/patina.zsh" ]] && source "$ZDOTDIR/patina.zsh"

# Load the interactive prompt before machine-local overrides.
[[ -f "$ZDOTDIR/prompt.zsh" ]] && source "$ZDOTDIR/prompt.zsh"

# Load machine-specific shell customizations when present.
[[ -f "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
