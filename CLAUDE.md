# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a dotfiles repository using Nix with Home Manager for declarative package and configuration management on macOS. Homebrew (via Brewfile) is used for GUI applications that are not available in Nix.

## Common Commands

```bash
# Apply Nix/Home Manager configuration
make nix

# Install Homebrew packages
make brew
```

## Architecture

### Core Structure

- `nix/flake.nix`: Nix flake definition
- `nix/home.nix`: Main Home Manager configuration (imports program modules and defines packages)
- `nix/programs/`: Per-program Nix configurations
- `config/`: Application configuration files (symlinked to `$HOME`)
- `Brewfile`: Homebrew packages (primarily GUI applications)
- `bin/nix-setup`: Script to install Nix and apply Home Manager configuration

### Adding New Packages

#### Nix Packages (CLI tools)

Add to `home.packages` in `nix/home.nix`:

```nix
home.packages = with pkgs; [
  # existing packages...
  new-package-name
];
```

#### Program with Configuration

Create a new file in `nix/programs/`:

```nix
# nix/programs/tool-name.nix
{ config, pkgs, ... }:

{
  programs.toolName = {
    enable = true;
    # additional configuration
  };
}
```

Then import it in `nix/home.nix`:

```nix
imports = [
  # existing imports...
  ./programs/tool-name.nix
];
```

#### Homebrew Cask (GUI apps)

Add to `Brewfile`:

```ruby
cask "app-name"
```

### Configuration Files Management

- Place application config files in `config/` directory matching the target location structure
- Files in `config/` are symlinked to `$HOME/` by Home Manager or manually
- For Nix-managed programs, prefer using Home Manager's native configuration options

## Memories

- dotfile管理を足すときは Home Manager の設定を使う
