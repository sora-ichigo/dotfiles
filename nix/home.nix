{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs/bash.nix
    ./programs/git.nix
    ./programs/gh.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
    ./programs/zsh.nix
    ./programs/mise.nix
    ./programs/direnv.nix
    ./programs/codex.nix
    ./programs/claude-code.nix
    ./programs/wezterm.nix
    ./programs/yabai.nix
    ./programs/git-worktree-runner.nix
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    yq
    wget
    curl
    htop
    fzf
    gnused
    bat
    lazygit
    coreutils
    libffi
    nnn
    awscli2
    luarocks
    libpq
    postgresql
    ghq
    fvm

    # Docker (Colima + CLI)
    docker
    docker-compose
    colima

  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS only
    terminal-notifier
  ];
}
