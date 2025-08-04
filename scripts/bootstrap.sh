#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/.zshrc.d}"   # repo is ~/.zshrc.d

msg()  { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; }

# Beginning message
msg "🚀 Starting zsh dotfiles bootstrap..."
msg "Repository: $REPO_DIR"

# Ensure Homebrew
find_brew() {
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && { echo "$b"; return 0; }
  done
  command -v brew 2>/dev/null || true
}
BREW="$(find_brew)"
[[ -z "$BREW" ]] && { err "Homebrew not found. Install from https://brew.sh"; exit 1; }

# Use brew's env for this script (PATH, MANPATH, etc.)
eval "$("$BREW" shellenv)"

# Install required packages (only if missing)
PKGS=(
  antidote # plugin manager
  starship # prompt
  zoxide # cd
  fzf # fuzzy finder
  mise # version manager
  uv # python package manager
  eza # ls
  bat # cat
  ripgrep # grep
  fd # find replacement
  delta # git diff viewer
  dust # du replacement
  procs # ps replacement
  httpie # curl alternative
  jq # json processor
  btop # system monitor
  killport # kill port
)
MISSING=()
for p in "${PKGS[@]}"; do
  "$BREW" list --versions "$p" >/dev/null 2>&1 || MISSING+=("$p")
done
if ((${#MISSING[@]})); then
  msg "brew install ${MISSING[*]}"
  "$BREW" install "${MISSING[@]}"
else
  msg "All Homebrew packages already present."
fi

# Configure delta git integration (only if not already included)
DELTA_GITCONFIG="$HOME/.zshrc.d/configs/delta/.gitconfig"
if ! git config --global --get-all include.path | grep -qx "$DELTA_GITCONFIG"; then
  git config --global --add include.path "$DELTA_GITCONFIG"
  msg "Added delta git config inclusion"
else
  msg "Delta git config already included"
fi

# Symlink ~/.zshrc -> ~/.zshrc.d/.zshrc (backup non-link if needed)
ZRC_TARGET="$HOME/.zshrc"
ZRC_SOURCE="$REPO_DIR/.zshrc"
if [[ -L "$ZRC_TARGET" && "$(readlink "$ZRC_TARGET")" == "$ZRC_SOURCE" ]]; then
  msg "~/.zshrc already linked to $ZRC_SOURCE"
elif [[ -e "$ZRC_TARGET" && ! -L "$ZRC_TARGET" ]]; then
  TS=$(date +%Y%m%d-%H%M%S)
  warn "~/.zshrc exists (not a symlink). Backing up to ~/.zshrc.bak.$TS"
  mv "$ZRC_TARGET" "$HOME/.zshrc.bak.$TS"
  ln -sfn "$ZRC_SOURCE" "$ZRC_TARGET"
  msg "Linked ~/.zshrc -> $ZRC_SOURCE"
else
  ln -sfn "$ZRC_SOURCE" "$ZRC_TARGET"
  msg "Linked ~/.zshrc -> $ZRC_SOURCE"
fi

# Final note
msg "Done. Reload shell with: reload (exec zsh -l)"
