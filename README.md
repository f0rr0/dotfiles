# 🚀 Modern Zsh Configuration

A modular, maintainable, and feature-rich Zsh configuration built for developers.

<p align="center">
  <img src="https://github.com/user-attachments/assets/37e0c593-28fb-4c1d-bd0b-20144c08419e" alt="Terminal Preview" width="800">
</p>

## 🏗️ Architecture

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

### Config Directory

The `configs/` directory contains external tool configurations.

## 📋 Requirements

### Homebrew (Required)

This configuration requires [Homebrew](https://brew.sh/) for package management:

```bash
# macOS
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Supported Platforms

- ✅ **macOS** (Apple Silicon & Intel)
- ✅ **Linux** (not tested)
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
- ✅ Verifies Homebrew installation
- ✅ Installs all required packages
- ✅ Symlinks `~/.zshrc` → `~/.zshrc.d/.zshrc`
- ✅ Backs up existing `~/.zshrc` if needed

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

The bootstrap script installs these packages via Homebrew:

**Modern CLI Replacements:**
- `eza` - Better `ls`
- `bat` - Better `cat`  
- `ripgrep` - Better `grep`
- `fd` - Better `find`
- `delta` - Better git diff
- `dust` - Better `du`
- `procs` - Better `ps`

---
