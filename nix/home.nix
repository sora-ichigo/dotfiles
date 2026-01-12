{ config, pkgs, ... }:

{
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
  ];
}
