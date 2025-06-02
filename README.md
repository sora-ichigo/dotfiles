# dotfiles 🥘
![](https://github.com/igsr5/dotfiles/workflows/Provisioning%20Test/badge.svg)

My development environment setup dotfiles

## Supported OS
- macOS (Darwin)
- Ubuntu
- Debian

## Tools
This dotfiles repository uses [Mitamae](https://github.com/itamae-kitchen/mitamae), a Ruby-based infrastructure automation tool, to provision development environments across multiple platforms.

## Installation
```sh
$ git clone https://github.com/igsr5/dotfiles.git
$ cd dotfiles
$ make
```

Dry run:
```sh
$ make mitamae-dry
```

## Directory Structure
```
.
├── bin/                    # Mitamae binary and setup scripts
├── config/                 # Application configuration files
├── cookbooks/             # Individual tool/application configurations
├── lib/                   # Core recipe files and helpers
├── roles/                 # Platform-specific role definitions
│   ├── base/             # Common configurations for all platforms
│   ├── darwin/           # macOS-specific configurations
│   ├── ubuntu/           # Ubuntu-specific configurations
│   └── debian/           # Debian-specific configurations
└── scripts/              # Utility scripts
```
