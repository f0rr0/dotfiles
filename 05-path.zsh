# 05-path.zsh — PATH management & search locations

# =============================================================================
# PATH array configuration
# =============================================================================

# Make PATH array unique to avoid duplicates when prepending paths
typeset -gU path

# =============================================================================
# Homebrew integration (macOS)
# =============================================================================

# Add Homebrew to PATH and set up environment
if [[ -x /opt/homebrew/bin/brew ]]; then
  # Apple Silicon Macs
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  # Intel Macs
  eval "$(/usr/local/bin/brew shellenv)"
fi
