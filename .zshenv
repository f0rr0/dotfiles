# .zshenv — Set ZDOTDIR to keep all zsh config in one place

# =============================================================================
# Zsh directory configuration
# =============================================================================

# Set ZDOTDIR so zsh looks for .zshrc and other files in ~/.zshrc.d/
export ZDOTDIR="$HOME/.zshrc.d"

# Non-login non-interactive shells do not read .zprofile or .zshrc.
# Login shells source .zprofile after macOS path_helper, so let that file
# apply this bootstrap later to keep Homebrew ahead of /usr/bin.
if [[ ! -o interactive && ! -o login ]]; then
  [[ -r "$ZDOTDIR/_noninteractive-essentials.zsh" ]] && source "$ZDOTDIR/_noninteractive-essentials.zsh"
fi
