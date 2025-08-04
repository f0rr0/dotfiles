# 60-aliases.zsh — aliases & tiny helpers (after PATH & plugins)

# =============================================================================
# Quick navigation & shell helpers
# =============================================================================

alias reload='exec zsh -l'
alias cls='clear'
alias dev='cd ~/Dev'
alias nom='npm'
alias gcm='git commit -m'

# Open configs in $EDITOR
zshrc()    { "${EDITOR:-nvim}" "$HOME/.zshrc"; }
dotfiles() { "${EDITOR:-nvim}" "$HOME/.zshrc.d"; }

# =============================================================================
# Enhanced command replacements (with fallbacks)
# =============================================================================

# ls family (eza with icons and git info)
if command -v eza >/dev/null; then
  alias ls='eza --icons=auto'
  alias ll='eza -l --group-directories-first --git --icons=auto'
  alias la='eza -la --icons=auto'
else
  alias ll='ls -l'
  alias la='ls -la'
fi

# grep with smart case matching
command -v rg >/dev/null && alias grep='rg --smart-case'

# cat with syntax highlighting (function for proper "$@" handling)
cat() {
  if command -v bat >/dev/null; then
    bat --paging=never "$@" 2>/dev/null || command cat "$@"
  else
    command cat "$@"
  fi
}

# =============================================================================
# Additional modern tool shortcuts (non-shadowing)
# =============================================================================

# fd with sensible defaults (as fdf to avoid shadowing find)
command -v fd >/dev/null && alias fdf='fd --hidden --follow --exclude .git'

# =============================================================================
# Cleanup conflicting aliases
# =============================================================================

# Remove Graphite alias if it exists
(( $+aliases[gt] )) && unalias gt
