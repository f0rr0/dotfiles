# 00-env.zsh — Core environment variables (no shell options)

# =============================================================================
# Core applications & tools
# =============================================================================

# Default editor/visual editor/pager
: ${EDITOR:=cursor}
: ${VISUAL:=$EDITOR}
: ${PAGER:=less}

# Browser helper for macOS
if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

# =============================================================================
# Locale & character encoding
# =============================================================================

# Consistent UTF-8 behavior across all tools
: ${LANG:=en_US.UTF-8}

# =============================================================================
# Pager configuration (less)
# =============================================================================

# less flags for better experience:
# -R: pass colors through, -S: chop long lines, -M: long prompt
# -i: smart case search, -g: highlight first match only
# -X: no clear screen, -w: highlight near EOF, -z-4: smooth scroll
: ${LESS:="-g -i -M -R -S -w -X -z-4"}

# Enable lesspipe for nicer previews (archives, etc.)
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# =============================================================================
# Shell history configuration
# =============================================================================

# Large, persistent, shared history across sessions
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
