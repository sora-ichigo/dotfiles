{ pkgs, ... }:

{
  home.packages = [ pkgs.gh ];

  home.file.".config/gh/config.yml".source = ../../config/.config/gh/config.yml;
}
