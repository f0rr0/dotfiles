# 15-keys.zsh — Key bindings & input configuration

# =============================================================================
# Input mode & word boundaries
# =============================================================================

# Use Emacs-style key bindings (change to -v for vi mode)
bindkey -e

# Define word boundaries for word-based navigation
# Remove - . / from WORDCHARS so they're treated as word separators
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

# =============================================================================
# Word navigation (Meta/Option + arrow keys)
# =============================================================================

# Meta+f / Meta+b (works when Option key sends Esc+)
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# Option+Arrow keys (iTerm2 and most modern terminals)
bindkey '\e[1;3C' forward-word   # Option+Right Arrow (⌥→)
bindkey '\e[1;3D' backward-word  # Option+Left Arrow (⌥←)

# =============================================================================
# Word deletion
# =============================================================================

bindkey '^[d' kill-word                 # Meta+d (delete word forward)
bindkey '\e\x7f' backward-kill-word     # Option+Backspace (⌥⌫)
bindkey '\e[3;3~' kill-word             # Option+Delete (⌥⌦) on some setups

# =============================================================================
# Basic editing
# =============================================================================

# Ensure backspace works correctly
bindkey '^H' backward-delete-char

# =============================================================================
# History navigation
# =============================================================================

# Up/Down arrows for incremental history substring search
# (requires zsh-history-substring-search plugin)
bindkey '^[[A' history-substring-search-up    # Up arrow (↑)
bindkey '^[[B' history-substring-search-down  # Down arrow (↓)
