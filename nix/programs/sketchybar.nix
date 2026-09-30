{ lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    programs.sketchybar = {
      enable = true;
      config = {
        source = ../../config/.config/sketchybar;
        recursive = true;
      };
      extraPackages = [ pkgs.jq ];
    };

    home.packages = [ pkgs.sketchybar-app-font ];

    targets.darwin.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
