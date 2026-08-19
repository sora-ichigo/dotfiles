{ pkgs, ... }:

{
  home.packages = [ pkgs.hunk ];

  home.file.".config/hunk/config.toml".source = ../../config/.config/hunk/config.toml;
}
