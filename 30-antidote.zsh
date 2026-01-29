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
fi

if [[ -n "$_antidote_prefix" ]]; then
  source "$_antidote_prefix/share/antidote/antidote.zsh"
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

# Generate plugin cache if needed (when plugin list is newer)
if [[ ! -f $PLUG_ZSH || $PLUG_TXT -nt $PLUG_ZSH ]]; then
  if command -v antidote >/dev/null; then
    antidote bundle < "$PLUG_TXT" >! "$PLUG_ZSH"
  else
    echo "Error: antidote command not available for plugin bundling" >&2
    return 1
  fi
fi

# Load generated plugin cache
if [[ -r "$PLUG_ZSH" ]]; then
  source "$PLUG_ZSH"
else
  echo "Error: Failed to load plugin cache at $PLUG_ZSH" >&2
  return 1
fi
