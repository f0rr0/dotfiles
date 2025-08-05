# 50-prompt.zsh — Starship prompt configuration

# =============================================================================
# Starship prompt setup
# =============================================================================

# Set custom Starship configuration location
export STARSHIP_CONFIG="$ZDOTDIR/configs/starship/config.toml"

# Initialize Starship prompt for zsh
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi
