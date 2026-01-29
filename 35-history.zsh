# 35-history.zsh — History search keybindings (after plugins)

# =============================================================================
# History navigation (zsh-history-substring-search)
# =============================================================================

# Up/Down arrows for incremental history substring search
# Bind only if the plugin functions are available
if (( $+functions[history-substring-search-up] && $+functions[history-substring-search-down] )); then
  bindkey '^[[A' history-substring-search-up    # Up arrow (↑)
  bindkey '^[[B' history-substring-search-down  # Down arrow (↓)
fi
