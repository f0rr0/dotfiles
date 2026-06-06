# 🚀 Modern Zsh Configuration

A blazing fast, maintainable, and feature-rich zsh configuration built for developers.

<p align="center">
  <img src="https://github.com/user-attachments/assets/37e0c593-28fb-4c1d-bd0b-20144c08419e" alt="Terminal Preview" width="800">
</p>

## 🏗️ Architecture

### ZDOTDIR Structure

This configuration uses zsh's `ZDOTDIR` mechanism to keep everything organized in `~/.zshrc.d/`:

1. **`.zshenv`** sets `ZDOTDIR="$HOME/.zshrc.d"`
2. **`.zprofile`** handles login-shell setup after macOS `path_helper`
3. **`.zshrc`** loads all numbered files in lexicographic order for interactive shells
4. **`_noninteractive-essentials.zsh`** gives scripts the expected PATH and mise setup without loading prompts/plugins/completions

### Numbered File System

Files are loaded in **lexicographic order** by the main `.zshrc` loader:

- **00-09**: Environment setup (variables, PATH)
- **10-19**: Core Zsh configuration (options, keybindings, tools)
- **20-29**: Completions and interactive features
- **30-39**: Plugin management and external integrations
- **50-59**: UI/UX (prompt, themes)
- **60-69**: User convenience (aliases, functions)
- **70-79**: Local/machine-specific overrides

> 💡 **Tip**: Prefix a file with `_` to disable it (e.g., `_30-antidote.zsh`)

### Shell Startup Split

Interactive shells load the full numbered configuration through `.zshrc`.

Non-interactive shells intentionally load only essentials:

- non-login scripts: `.zshenv` sources `_noninteractive-essentials.zsh`
- login scripts: `.zprofile` sources `_noninteractive-essentials.zsh` after macOS `path_helper`

This keeps Homebrew, user-local binaries, and mise-managed tools available in scripts while avoiding prompt, completion, and plugin startup cost outside interactive shells.

Ignored local overrides such as `70-local.zsh` are not loaded in non-interactive shells by default. To opt in for a specific script, set:

```bash
ZSH_LOAD_LOCAL_IN_NONINTERACTIVE=1 zsh -lc '...'
```

### Config Directory

The `configs/` directory contains external tool configurations.

## 📋 Requirements

### Package Managers

On macOS, this configuration uses [Homebrew](https://brew.sh/) for package management:

```bash
# macOS
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Ubuntu/Debian, `scripts/bootstrap.sh` uses `apt` for system packages and installs Antidote, Starship, mise, and uv into user-local paths when needed.

### Supported Platforms

- ✅ **macOS** (Apple Silicon & Intel)
- ✅ **Linux** (Ubuntu/Debian remote hosts)
- ❌ Windows (not tested)

## ⚡ Quick Start

### 1. Clone Repository

```bash
git clone git@github.com:f0rr0/dotfiles.git ~/.zshrc.d
cd ~/.zshrc.d
```

### 2. Run Bootstrap Script

The bootstrap script handles everything automatically:

```bash
./scripts/bootstrap.sh
```

**What it does:**
- ✅ Installs required packages via Homebrew on macOS or apt/user-local installers on Ubuntu/Debian
- ✅ Symlinks `~/.zshenv` → `~/.zshrc.d/.zshenv`
- ✅ Backs up existing `~/.zshenv` if needed
- ✅ Installs mise-managed runtimes from `configs/mise/config.toml`

### 3. Reload Shell

```bash
exec zsh -l
```

## 🛠️ Key Tools & Configurations

### 🔌 Antidote (Plugin Manager)

**Ultra-fast plugin manager** that generates static loading scripts for maximum performance.

[📖 Learn more about Antidote](https://getantidote.github.io/)

### 🔄 Mise (Version Manager)

**Modern alternative to nvm, rbenv, pyenv** - manage Node.js, Python, Ruby, and 100+ other tools.

[📖 Learn more about Mise](https://mise.jdx.dev/)

### 🔍 FZF (Fuzzy Finder)

**Command-line fuzzy finder** with extensive customization for file navigation, history search and autocompletions.

[📖 Learn more about FZF](https://github.com/junegunn/fzf)

### 🏃 Zoxide (Smart CD)

**Smarter cd command** that learns your habits and lets you jump to directories with minimal typing.

[📖 Learn more about Zoxide](https://github.com/ajeetdsouza/zoxide)

### 🖥️ iTerm2 Integration (Optional)

[📖 Learn more about iTerm2 Shell Integration](https://iterm2.com/documentation-shell-integration.html#install-by-hand)

## 🎨 Customization

### Local Overrides

Create `70-local.zsh` (git-ignored) for machine-specific customizations:

```bash
# ~/.zshrc.d/70-local.zsh
export EDITOR="code"
alias ll="eza -la --git --icons"

# Add work-specific PATH
path=(/opt/work/bin $path)
```

## 📦 Installed Packages

The bootstrap script installs these packages via Homebrew on macOS or apt/user-local installers on Ubuntu/Debian:

**Modern CLI Replacements:**
- `eza` - Better `ls`
- `bat` - Better `cat`  
- `ripgrep` - Better `grep`
- `fd` - Better `find`
- `delta` - Better git diff
- `gh` - GitHub CLI
- `dust` - Better `du` (Homebrew path)
- `procs` - Better `ps` (Homebrew path)

---
