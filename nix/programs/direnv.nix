{ pkgs, config, ... }:

{
  home.packages = [ pkgs.direnv ];

  home.file.".config/direnv/direnv.toml".source = ../../config/.config/direnv/direnv.toml;
}
