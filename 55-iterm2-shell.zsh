# 55-iterm2-shell.zsh — iTerm2 shell integration

# =============================================================================
# iTerm2 shell integration
# =============================================================================

# Install shell integration via iTerm2 menu: iTerm2 > Install Shell Integration
# Or manually: https://iterm2.com/documentation-shell-integration.html#install-by-hand

# Load iTerm2 shell integration if available (must load after prompt)
[[ -r "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"
