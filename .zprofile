# .zprofile — login-shell configuration

# macOS /etc/zprofile runs path_helper before this file and can move /usr/bin
# ahead of Homebrew. Non-interactive login shells do not read .zshrc, so apply
# the essential toolchain setup here after path_helper has finished.
if [[ ! -o interactive ]]; then
  [[ -r "$ZDOTDIR/_noninteractive-essentials.zsh" ]] && source "$ZDOTDIR/_noninteractive-essentials.zsh"
fi
