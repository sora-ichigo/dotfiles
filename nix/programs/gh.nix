{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
  };

  home.file.".config/gh/config.yml".source = ../../config/.config/gh/config.yml;
}
