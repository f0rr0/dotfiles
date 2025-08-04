# 10-options.zsh — Shell behavior & options configuration

# =============================================================================
# Prompt & expansion options
# =============================================================================

# Allow prompt to expand $(...) and other substitutions (needed by modern prompts)
setopt prompt_subst

# =============================================================================
# Quality of life improvements
# =============================================================================

setopt interactivecomments   # Allow comments after commands in interactive shell
setopt autocd                # Typing a directory name = cd into it
setopt extendedglob          # Enable powerful globbing patterns
setopt noshwordsplit         # Safer word-splitting in parameter expansion
setopt nohup                 # Keep jobs running on hangup
setopt nobeep                # Silence the terminal bell

# =============================================================================
# Directory navigation enhancements
# =============================================================================

setopt auto_pushd            # cd acts like pushd (maintains directory stack)
setopt pushd_ignore_dups     # Don't push duplicate directories onto stack
setopt pushd_silent          # Don't print directory stack after pushd/popd

# =============================================================================
# Globbing & pattern matching
# =============================================================================

setopt glob_dots             # Include dotfiles in globs (e.g., * matches .hidden)
setopt numeric_glob_sort     # Sort numerically when possible (file1 file2 file10)
setopt mark_dirs             # Append trailing slash to directory names from globs

# =============================================================================
# Completion
# =============================================================================

setopt list_packed           # Make completion lists more compact
setopt auto_list             # Automatically list choices on ambiguous completion

# =============================================================================
# History management
# =============================================================================

# Advanced history options for better experience
setopt hist_ignore_all_dups  # Remove older duplicate entries from history
setopt hist_reduce_blanks    # Trim unnecessary whitespace from history entries
setopt share_history         # Share history between all terminal sessions
setopt inc_append_history    # Append to history incrementally (real-time)
