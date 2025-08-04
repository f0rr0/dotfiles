# 18-mise.zsh — Mise version manager integration

# =============================================================================
# Mise configuration
# =============================================================================

# Set custom global config location
export MISE_GLOBAL_CONFIG_FILE="$HOME/.zshrc.d/configs/mise/config.toml"

# =============================================================================
# Mise initialization
# =============================================================================

# Initialize mise for version management (Node.js, Python, Ruby, etc.)
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi
