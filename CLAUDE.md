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
2. Add to appropriate role file:
   ```ruby
   include_cookbook 'package-name'
   ```

#### Homebrew Cask (GUI apps)

1. Create `cookbooks/[package-name]/default.rb` with:
   ```ruby
   brew_cask_package 'package-name'
   ```
2. Add to appropriate role file
3. If app name differs from package name, update `app_name_map` in `recipe_helper.rb`

### Platform Detection

- Uses `node[:platform]` to determine OS (darwin, ubuntu, debian)
- Architecture detection in `brew_prefix` helper supports both x86_64 and arm64
- Platform-specific roles handle OS-specific package management

