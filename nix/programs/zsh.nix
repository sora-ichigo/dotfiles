{ pkgs, ... }:

{
  home.packages = [ pkgs.zsh ];

  home.file.".zshrc".source = ../../config/.zshrc;
  home.file.".zsh".source = ../../config/.zsh;
}
