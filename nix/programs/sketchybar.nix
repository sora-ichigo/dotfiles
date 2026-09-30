{ config, lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    programs.sketchybar = {
      enable = true;
      config = {
        source = ../../config/.config/sketchybar;
        recursive = true;
      };
      extraPackages = [
        pkgs.jq
        pkgs.sketchybar-app-font
      ];
    };

    launchd.agents.sketchybar.config.EnvironmentVariables = {
      PATH = "${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.nix-profile/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      LANG = "en_US.UTF-8";
    };

    home.packages = [ pkgs.sketchybar-app-font ];
  };
}
