# 25-fzf.zsh — env + defaults for fzf

# Use a tmux popup when inside tmux (cleaner UI)
export FZF_TMUX=1
export FZF_TMUX_OPTS='-p 80%,70%'

# Nice default look (reverse list, border, inline info, 60% height)
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --info=inline
  --marker=' '
  --bind=alt-j:down,alt-k:up,alt-u:half-page-up,alt-d:half-page-down
"

# Configure fzf history search (Ctrl-R)
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' 
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
"

# Prefer fd for file/dir sources; fall back to find
if command -v fd >/dev/null; then
  # Ctrl-T: show files (hidden, follow symlinks, ignore .git)
  export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git"
  # Alt-C: jump to directories
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
else
  export FZF_CTRL_T_COMMAND="command find -L . -type f -not -path '*/\.git/*' 2>/dev/null"
  export FZF_ALT_C_COMMAND="command find -L . -type d -not -path '*/\.git/*' 2>/dev/null"
fi

# Previews: bat for files if available; otherwise head
if command -v bat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right,60%"
else
  export FZF_CTRL_T_OPTS="--preview 'head -n 200 {}' --preview-window=right,60%"
fi
# For Alt-C, preview directory tree with eza or plain tree/find
if command -v eza >/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza -lah --git --icons=auto --group-directories-first {} | head -n 200' --preview-window=right,60%"
else
  export FZF_ALT_C_OPTS="--preview 'command ls -la {} | head -n 200' --preview-window=right,60%"
fi

# Load fzf shell integration (Homebrew)
_brew_prefix="$(brew --prefix)"

# Load completion first (doesn't conflict with compinit already run)
[[ -r "$_brew_prefix/opt/fzf/shell/completion.zsh" ]] && \
  source "$_brew_prefix/opt/fzf/shell/completion.zsh"

# Load key bindings for Ctrl-T (files), Alt-C (cd), and Ctrl-R (history)
if [[ -r "$_brew_prefix/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$_brew_prefix/opt/fzf/shell/key-bindings.zsh"
fi

unset _brew_prefix

# ff: fuzzy open a file in $EDITOR
ff() {
  local file
  file="$(eval "$FZF_CTRL_T_COMMAND" | fzf)" || return
  [[ -n "$file" ]] && "${EDITOR:-nvim}" "$file"
}

# cdf: fuzzy cd into a subdirectory
cdf() {
  local dir
  dir="$(eval "$FZF_ALT_C_COMMAND" | fzf)" || return
  [[ -n "$dir" ]] && cd "$dir"
}
