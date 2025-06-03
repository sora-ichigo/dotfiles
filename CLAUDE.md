# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a dotfiles repository using Mitamae (Ruby-based infrastructure automation tool) to provision development environments across macOS, Ubuntu, and Debian platforms. The architecture follows a cookbook-based pattern where each tool/application has its own cookbook with installation and configuration logic.

## Common Commands

### Initial Setup

```bash
# First time installation
curl -sSL https://raw.githubusercontent.com/igsr5/dotfiles/master/install.sh | sh

# Subsequent runs
make

# Dry run (see what would be changed without applying)
make mitamae-dry
```

### Development Commands

```bash
# Run Mitamae directly
./bin/mitamae local ./lib/recipe.rb

# List Cursor extensions to file
make list-extensions
```

## Architecture

### Core Structure

- `lib/recipe.rb`: Main entry point that includes platform-specific roles
- `lib/recipe_helper.rb`: Helper methods and cookbook inclusion logic
- `roles/`: Platform-specific role definitions (darwin, ubuntu, debian, base)
- `cookbooks/`: Individual tool/application configurations
- `bin/setup`: Downloads and sets up the appropriate Mitamae binary
- `config/`: Application configuration files

### Recipe Execution Flow

1. `lib/recipe.rb` determines the platform and includes the appropriate role
2. Roles (e.g., `roles/darwin/default.rb`) include specific cookbooks
3. Cookbooks contain installation and configuration logic for individual tools
4. `recipe_helper.rb` provides helper methods like `brew_cask_package` for macOS apps

### Adding New Packages

#### Homebrew Formula (CLI tools)

1. Create `cookbooks/[package-name]/default.rb` with:
   ```ruby
   package 'package-name'
   ```
   **Important**: Use exact package name from `brew info [package-name]`. For example, `rg` command is actually `ripgrep` package.

2. Add to appropriate role file:
   ```ruby
   include_cookbook 'package-name'
   ```

#### Homebrew Cask (GUI apps)

1. Create `cookbooks/[package-name]/default.rb` with:
   ```ruby
   brew_cask_package 'package-name'
   ```
   **Important**: Use exact package name from `brew info --cask [package-name]`.

2. Add to appropriate role file
3. If app name differs from package name, update `app_name_map` in `recipe_helper.rb:116`

### Configuration Files Management

- Place application config files in `config/` directory matching the target location structure
- **ALWAYS use `dotfile` method for managing configuration files** (defined in `cookbooks/functions/default.rb`)
- The `dotfile` method creates symbolic links from `config/[path]` to `$HOME/[path]`
- Consider platform differences when handling config file paths

#### Using dotfile Method

```ruby
# Basic usage: config/.tmux.conf → ~/.tmux.conf
dotfile '.tmux.conf'

# Directory linking: config/.config/nvim → ~/.config/nvim  
dotfile '.config/nvim'

# macOS specific paths: config/Library/... → ~/Library/...
dotfile "Library/Application Support/App/settings.json"
```

**Important**: Always use `dotfile` method instead of `remote_file` for configuration management.

### Platform Detection

- Uses `node[:platform]` to determine OS (darwin, ubuntu, debian)
- Architecture detection in `brew_prefix` helper supports both x86_64 and arm64
- Platform-specific roles handle OS-specific package management

### Key Helper Methods

- `dotfile(name)`: Creates symbolic link from `config/[name]` to `$HOME/[name]` (defined in `cookbooks/functions/default.rb`)
- `brew_cask_package(name)`: Installs Homebrew Cask packages with app existence checking
- `include_cookbook(name)`: Loads cookbook from `cookbooks/[name]/default.rb`
- `include_role(name)`: Loads role from `roles/[name]/default.rb`
- `has_package?(name)`: Checks if Debian package is installed
- `brew_prefix`: Returns architecture-appropriate Homebrew prefix (`/usr/local` or `/opt/homebrew`)

## Memories

- dotfile管理を足すときはdotfile メソッドを使って設定を書いて