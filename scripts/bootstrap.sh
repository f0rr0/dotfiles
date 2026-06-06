#!/usr/bin/env bash
set -euo pipefail

ZDOTDIR="${ZDOTDIR:-$HOME/.zshrc.d}"   # repo is ~/.zshrc.d

msg()  { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; }

# Beginning message
msg "Starting zsh dotfiles bootstrap..."
msg "Repository: $ZDOTDIR"

OS="$(uname -s)"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

find_brew() {
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && { echo "$b"; return 0; }
  done
  command -v brew 2>/dev/null || true
}

install_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    msg "Installing mise"
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
  fi
}

install_uv() {
  if ! command -v uv >/dev/null 2>&1; then
    msg "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

install_antidote() {
  local target="$HOME/.local/share/antidote"
  if [[ ! -r "$target/antidote.zsh" && ! -r "$target/share/antidote/antidote.zsh" ]]; then
    msg "Installing Antidote"
    rm -rf "$target"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$target"
  fi
}

install_starship() {
  if ! command -v starship >/dev/null 2>&1; then
    msg "Installing Starship"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
  fi
}

install_macos_packages() {
  local brew
  brew="$(find_brew)"
  [[ -z "$brew" ]] && { err "Homebrew not found. Install from https://brew.sh"; exit 1; }

  eval "$("$brew" shellenv)"
  PKGS=(
    antidote
    starship
    zoxide
    fzf
    gh
    mise
    uv
    eza
    bat
    ripgrep
    fd
    delta
    dust
    procs
    httpie
    jq
    btop
    killport
  )

  MISSING=()
  for p in "${PKGS[@]}"; do
    "$brew" list --versions "$p" >/dev/null 2>&1 || MISSING+=("$p")
  done

  if ((${#MISSING[@]})); then
    msg "brew install ${MISSING[*]}"
    "$brew" install "${MISSING[@]}"
  else
    msg "All Homebrew packages already present."
  fi
}

install_linux_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    msg "Configuring GitHub CLI apt repository"
    sudo mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
      sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    msg "Installing Ubuntu/Debian packages"
    sudo apt-get update
    sudo apt-get install -y \
      zsh git curl ca-certificates unzip less lsof procps \
      build-essential pkg-config cmake make \
      fzf ripgrep fd-find bat eza zoxide git-delta httpie jq btop \
      gh neovim tmux direnv
  else
    warn "No apt-get found; installing only user-local tools"
  fi

  mkdir -p "$HOME/.local/bin"

  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  install_mise
  install_uv
  install_antidote
  install_starship
}

case "$OS" in
  Darwin)
    install_macos_packages
    ;;
  Linux)
    install_linux_packages
    ;;
  *)
    warn "Unsupported OS '$OS'; installing user-local tools only"
    install_mise
    install_uv
    install_antidote
    install_starship
    ;;
esac

export MISE_GLOBAL_CONFIG_FILE="$ZDOTDIR/configs/mise/config.toml"
if command -v mise >/dev/null 2>&1; then
  msg "Installing mise-managed runtimes"
  mise install
  mise reshim >/dev/null 2>&1 || true
fi

# Configure delta git integration (only if not already included)
DELTA_GITCONFIG="$ZDOTDIR/configs/delta/.gitconfig"
if ! git config --global --get-all include.path | grep -qx "$DELTA_GITCONFIG"; then
  git config --global --add include.path "$DELTA_GITCONFIG"
  msg "Added delta git config inclusion"
else
  msg "Delta git config already included"
fi

# Symlink ~/.zshenv -> ~/.zshrc.d/.zshenv (backup non-link if needed)
ZSHENV_TARGET="$HOME/.zshenv"
ZSHENV_SOURCE="$ZDOTDIR/.zshenv"
if [[ -L "$ZSHENV_TARGET" && "$(readlink "$ZSHENV_TARGET")" == "$ZSHENV_SOURCE" ]]; then
  msg "$HOME/.zshenv already linked to $ZSHENV_SOURCE"
elif [[ -e "$ZSHENV_TARGET" && ! -L "$ZSHENV_TARGET" ]]; then
  TS=$(date +%Y%m%d-%H%M%S)
  warn "$HOME/.zshenv exists (not a symlink). Backing up to $HOME/.zshenv.bak.$TS"
  mv "$ZSHENV_TARGET" "$HOME/.zshenv.bak.$TS"
  ln -sfn "$ZSHENV_SOURCE" "$ZSHENV_TARGET"
  msg "Linked ~/.zshenv -> $ZSHENV_SOURCE"
else
  ln -sfn "$ZSHENV_SOURCE" "$ZSHENV_TARGET"
  msg "Linked ~/.zshenv -> $ZSHENV_SOURCE"
fi

if command -v zsh >/dev/null 2>&1; then
  CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || true)"
  TARGET_SHELL="$(command -v zsh)"
  if [[ "$CURRENT_SHELL" != "$TARGET_SHELL" ]]; then
    warn "Login shell is $CURRENT_SHELL; switch with: chsh -s $TARGET_SHELL"
  fi
fi

# Final note
msg "Done. Reload shell with: reload (exec zsh -l)"
