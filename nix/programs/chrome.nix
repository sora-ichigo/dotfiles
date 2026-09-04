{ lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    targets.darwin.defaults."com.google.Chrome".NSUserKeyEquivalents = {
      "垂直タブを閉じる" = "~^b";
    };
  };
}
