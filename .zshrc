# ~/.zshrc — Modular zsh configuration loader
#
# This is a minimal loader that sources all configuration files from ~/.zshrc.d/
# Each topic (environment, completions, plugins, etc.) lives in its own file
# for better organization and maintainability.

# =============================================================================
# Modular configuration loader
# =============================================================================

# Directory containing modular zsh configuration files
export ZSHRC_D="$HOME/.zshrc.d"

# Source all .zsh files in lexicographic order (00-env.zsh, 05-path.zsh, etc.)
# Pattern notes:
#  - [^_]*.zsh  => files NOT starting with "_" (prefix "_" to disable a file)
#  - (Nn)       => N: nullglob (ignore if none), n: sort by name
for f in "$ZSHRC_D"/[^_]*.zsh(Nn); do
  source "$f"
done

# Clean up
unset f

# bun completions
[ -s "/Users/sid/.bun/_bun" ] && source "/Users/sid/.bun/_bun"
