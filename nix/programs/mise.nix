{ pkgs, ... }:

{
  home.packages = [ pkgs.mise ];

  home.file.".config/mise/config.toml".source = ../../config/.config/mise/config.toml;
}
