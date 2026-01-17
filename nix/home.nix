{ config, pkgs, ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/gh.nix
    ./programs/starship.nix
    ./programs/tmux.nix
  ];

  home.username = "ichigo";
  home.homeDirectory = "/Users/ichigo";
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
    direnv
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
    mise
  ];

  home.file.".config/mise/config.toml".source = ../config/.config/mise/config.toml;
}
