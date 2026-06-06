# _noninteractive-essentials.zsh — shared non-interactive shell bootstrap
#
# Keep this file focused on tools that scripts expect to resolve without
# requiring an interactive shell: PATH, mise, and local overrides.

for f in 05-path.zsh 06-android-java.zsh 18-mise.zsh; do
  [[ -r "$ZDOTDIR/$f" ]] && source "$ZDOTDIR/$f"
done
unset f

if [[ "${ZSH_LOAD_LOCAL_IN_NONINTERACTIVE:-0}" == "1" ]]; then
  [[ -r "$ZDOTDIR/70-local.zsh" ]] && source "$ZDOTDIR/70-local.zsh"
fi
