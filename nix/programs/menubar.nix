{ lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    targets.darwin.currentHostDefaults.NSGlobalDomain = {
      NSStatusItemSpacing = 6;
      NSStatusItemSelectionPadding = 6;
    };
  };
}
