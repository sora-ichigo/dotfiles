{ config, pkgs, ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/gh.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
    ./programs/zsh.nix
    ./programs/mise.nix
    ./programs/direnv.nix
    ./programs/codex.nix
    ./programs/wezterm.nix
    ./programs/yabai.nix
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    wget
    curl
    htop
    gnumake
    gcc
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
  ];
}
