{ pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];

  home.file.".config/lazygit/config.yml".source = ../../config/lazygit/config.yml;
}
