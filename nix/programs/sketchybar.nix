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

    home.activation.restartSketchybar = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
      run /bin/launchctl kickstart -k "gui/$UID/org.nix-community.home.sketchybar" 2>/dev/null || true
    '';
  };
}
