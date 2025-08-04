# 26-fzf-tab.zsh — fzf-tab configuration

# fzf-tab: Replace zsh's default completion selection menu with fzf
# Note: This runs after completions (20-completions.zsh) but before syntax highlighting

# Basic configuration for fzf-tab
if command -v fzf >/dev/null; then
  # Disable sort when completing git checkout (shows branches in chronological order)
  zstyle ':completion:*:git-checkout:*' sort false
  
  # Set descriptions format to enable group support 
  # NOTE: This causes dot prefixes in fzf-tab, so disabled for clean completions
  # zstyle ':completion:*:descriptions' format '[%d]'
  
  # Enable filename colorizing using LS_COLORS
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  
  # Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
  zstyle ':completion:*' menu no
  
  # Preview directory's content with eza when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
  
  # Show file content preview for regular files (but not directories, handled above)
  zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -f $realpath ]] && (bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || head -200 $realpath)'
  
  # Make fzf-tab follow FZF_DEFAULT_OPTS (inherits your fzf settings)
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  
  # Switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
  
  # Use tmux popup if available (requires tmux >= 3.2)
  if [[ -n "$TMUX" ]] && command -v tmux >/dev/null && command -v ftb-tmux-popup >/dev/null; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  fi
  
  # Completion styling for specific commands
  
  # Git log preview
  zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git show --color=always ${(Q)word}'
  
  # Process list with details
  zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -f -p $word'
  
  # Environment variables
  zstyle ':fzf-tab:complete:export:*' fzf-preview 'echo ${(P)word}'
  zstyle ':fzf-tab:complete:unset:*' fzf-preview 'echo ${(P)word}'
  
  # Package manager previews (if available)
  zstyle ':fzf-tab:complete:brew-install:*' fzf-preview 'brew info $word 2>/dev/null'
  
  # Man pages
  zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word | head -50'
  
  # Enable continuous completion (useful for deep paths)
  zstyle ':fzf-tab:*' continuous-trigger '/'
  
  # Configure multi-select
  zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:select'
fi