{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  home.file.".tmux.conf".source = ../../config/.tmux.conf;
  home.file.".tmux".source = ../../config/.tmux;
}
