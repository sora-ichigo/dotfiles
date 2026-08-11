{ pkgs, ... }:

{
  home.packages = [ pkgs.herdr ];

  home.file.".config/herdr/config.toml".source = ../../config/.config/herdr/config.toml;
}
