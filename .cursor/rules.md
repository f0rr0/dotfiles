# Cursor Rules for ~/.zshrc.d

## README Synchronization

When making changes to configuration files, **ALWAYS** check if the README.md needs updates to stay synchronized:

### Required Updates

1. **File Structure Changes**
   - Adding/removing/renaming `.zsh` files → Update "Directory Structure" section
   - Changes to `configs/` subdirectories → Update directory tree
   - New numbered files → Verify numbering explanation is accurate

2. **Tool Configuration Changes**
   - Modifying tool settings → Update relevant tool section in README
   - Adding new tools to bootstrap.sh → Update "Installed Packages" section
   - Changing plugin list in `configs/antidote/.zsh_plugins.txt` → Update "Configured Plugins"

3. **Functional Changes**
   - New aliases/functions → Update examples if documented
   - Keybinding changes → Update keybinding documentation
   - Environment variable changes → Update configuration examples

4. **Bootstrap Script Changes**
   - Package additions/removals → Update requirements and package lists
   - New setup steps → Update "What it does" section
   - Requirement changes → Update "Requirements" section

### Synchronization Rules

- **Accuracy First**: Whatever README documents MUST match actual implementation
- **Selective Documentation**: README doesn't need to document everything, but what it does document must be correct
- **Version Consistency**: Tool versions, configuration options, and examples must reflect current setup
- **Example Validation**: All code examples and command snippets must work with current configuration

## Code Style Rules

### File Organization
- Use numbered prefixes for load order: `00-env.zsh`, `05-path.zsh`, etc.
- Group related functionality in same number range
- Prefix with `_` to disable a file: `_30-antidote.zsh`

### Documentation
- Add header comments with purpose and key features
- Use `# =============================================================================` for major sections
- Document complex logic inline
- Include usage examples for custom functions

### Consistency
- Use `command -v tool >/dev/null` for tool existence checks
- Use `eval "$(tool generate-completion)"` pattern for completions
- Use consistent variable naming: `TOOL_CONFIG_FILE`, `_tool_prefix`
- Use `typeset -gU` for unique arrays (path, fpath)

### Error Handling
- Check tool availability before configuring
- Provide fallbacks for missing dependencies
- Use `return 1` for non-fatal errors in sourced files
- Add helpful error messages pointing to bootstrap script

## Testing Requirements

Before committing changes:

1. **Test in fresh shell**: `exec zsh -l`
2. **Verify completions work**: Test documented tools
3. **Check bootstrap script**: Run on clean system if possible
4. **Validate README**: Ensure all examples and instructions work
5. **Test error conditions**: Verify graceful handling of missing tools

---

**Remember: The goal is to maintain a professional, accurate, and helpful README that serves both new users and contributors effectively.**