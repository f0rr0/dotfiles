# 20-completions.zsh — Completion system initialization & configuration

# =============================================================================
# Completion system initialization
# =============================================================================

# Load completion system modules
zmodload -i zsh/complist
autoload -Uz compinit

# Set completion cache location (includes zsh version to avoid conflicts)
_compdump="$HOME/.zcompdump-$ZSH_VERSION"

# Initialize completion system with caching:
# - "compinit -d FILE" writes cache to specified location
# - "-C" uses existing cache without security checks (faster)
# - Rebuild cache if missing or older than 7 days
if [[ ! -f $_compdump || $_compdump(N.mh+7) ]]; then
  compinit -d $_compdump
else
  compinit -C -d $_compdump
fi

# =============================================================================
# Completion behavior & matching
# =============================================================================

# Group completion matches by category
zstyle ':completion:*' group-name ''

# Smart matching patterns:
# - Case-insensitive matching (m:{a-z}={A-Z})
# - Treat . _ - as word separators for partial matching
# - Allow fuzzy matching from left and right sides
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z} r:|[._-]=** l:|=* r:|=*'
