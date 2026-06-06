# 18-mise.zsh — Mise version manager integration

# =============================================================================
# Mise configuration
# =============================================================================

# Set custom global config location
export MISE_GLOBAL_CONFIG_FILE="$ZDOTDIR/configs/mise/config.toml"

# =============================================================================
# Mise initialization
# =============================================================================

# Initialize mise for version management (Node.js, Python, Ruby, etc.)
if command -v mise >/dev/null; then
  if [[ -o interactive ]]; then
    eval "$(mise activate zsh)"
  else
    # Apply per-directory overrides for non-interactive shells.
    __mise_noninteractive_env() {
      eval "$(mise hook-env -s zsh --quiet)"
    }

    __mise_noninteractive_env

    # Re-apply overrides after cd in non-interactive scripts.
    if [[ ${chpwd_functions[(Ie)__mise_noninteractive_env]} -eq 0 ]]; then
      chpwd_functions+=(__mise_noninteractive_env)
    fi
  fi
fi
