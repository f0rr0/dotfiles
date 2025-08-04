# 28-zoxide.zsh — Zoxide smart cd replacement

# =============================================================================
# Zoxide initialization
# =============================================================================

# Initialize zoxide for smart directory jumping
# Provides 'z' command for fuzzy directory navigation based on frecency
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi