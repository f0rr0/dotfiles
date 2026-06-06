# 30-antidote.zsh — Antidote plugin manager integration

# =============================================================================
# Antidote initialization
# =============================================================================

# Load Antidote from Homebrew installation without calling brew
_antidote_prefix=""
if [[ -n "$HOMEBREW_PREFIX" && -r "$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh" ]]; then
  _antidote_prefix="$HOMEBREW_PREFIX/opt/antidote"
elif [[ -r "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" ]]; then
  _antidote_prefix="/opt/homebrew/opt/antidote"
elif [[ -r "/usr/local/opt/antidote/share/antidote/antidote.zsh" ]]; then
  _antidote_prefix="/usr/local/opt/antidote"
elif [[ -r "$HOME/.local/share/antidote/antidote.zsh" ]]; then
  _antidote_prefix="$HOME/.local/share/antidote"
fi

if [[ -n "$_antidote_prefix" ]]; then
  if [[ -r "$_antidote_prefix/share/antidote/antidote.zsh" ]]; then
    source "$_antidote_prefix/share/antidote/antidote.zsh"
  else
    source "$_antidote_prefix/antidote.zsh"
  fi
  unset _antidote_prefix
else
  echo "Antidote not found. Run scripts/bootstrap.sh to install required packages." >&2
  return 1
fi

# =============================================================================
# Plugin cache management
# =============================================================================

# Plugin list and generated cache locations
PLUG_TXT="$ZDOTDIR/configs/antidote/.zsh_plugins.txt"
PLUG_ZSH="$ZDOTDIR/configs/antidote/.zsh_plugins.zsh"

# Verify plugin list exists
if [[ ! -f "$PLUG_TXT" ]]; then
  echo "Error: Plugin list not found at $PLUG_TXT" >&2
  return 1
fi

# Generate plugin cache when needed:
# - first run
# - plugin list changed
# - generated cache references missing plugin files
_needs_bundle=0
if [[ ! -f "$PLUG_ZSH" || "$PLUG_TXT" -nt "$PLUG_ZSH" ]]; then
  _needs_bundle=1
elif [[ -r "$PLUG_ZSH" ]]; then
  while IFS= read -r _source_path; do
    _source_path=${_source_path#\"}
    _source_path=${_source_path%\"}
    _source_path=${_source_path//\$HOME/$HOME}
    if [[ ! -e "$_source_path" ]]; then
      _needs_bundle=1
      break
    fi
  done < <(grep -oE '"\$HOME/[^"]+"' "$PLUG_ZSH")
fi

if (( _needs_bundle )); then
  if command -v antidote >/dev/null; then
    antidote bundle < "$PLUG_TXT" >! "$PLUG_ZSH"
  else
    echo "Error: antidote command not available for plugin bundling" >&2
    return 1
  fi
fi

unset _needs_bundle _source_path

# Load generated plugin cache
if [[ -r "$PLUG_ZSH" ]]; then
  source "$PLUG_ZSH"
else
  echo "Error: Failed to load plugin cache at $PLUG_ZSH" >&2
  return 1
fi
