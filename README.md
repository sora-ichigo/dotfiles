# dotfiles

My development environment setup dotfiles

## Supported OS

- macOS (Darwin)

## Tools

- [Nix](https://nixos.org/) with [Home Manager](https://github.com/nix-community/home-manager) for declarative package and configuration management
- [Homebrew](https://brew.sh/) with Brewfile for macOS GUI applications

## Installation

```sh
git clone https://github.com/igsr5/dotfiles.git
cd dotfiles
make nix    # Install Nix packages and apply Home Manager configuration
make brew   # Install Homebrew packages from Brewfile
```

## Directory Structure

```
.
├── install.sh              # Setup script for Nix and Home Manager
├── config/                 # Application configuration files (symlinked to $HOME)
├── nix/                    # Nix flake and Home Manager configuration
│   ├── flake.nix          # Nix flake definition
│   ├── home.nix           # Home Manager configuration
│   └── programs/          # Per-program Nix configurations
└── Brewfile               # Homebrew packages (GUI apps)
```
