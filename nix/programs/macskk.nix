{ config, lib, pkgs, ... }:

let
  skkJisyoMozc = pkgs.runCommand "skk-jisyo-mozc-${pkgs.mozc.version}" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    mkdir -p $out/share/skk
    python3 -I ${./macskk/mozc2skk.py} $out/share/skk/SKK-JISYO.mozc ${pkgs.mozc.src}/src/data/dictionary_oss/dictionary*.txt
  '';
  dictionaries = [
    "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
    "${skkJisyoMozc}/share/skk/SKK-JISYO.mozc"
  ];
in
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.macskkDictionaries = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      container="${config.home.homeDirectory}/Library/Containers/net.mtgto.inputmethod.macSKK/Data"
      if [ -d "$container" ]; then
        dir="$container/Documents/Dictionaries"
        for src in ${lib.escapeShellArgs dictionaries}; do
          dst="$dir/$(basename "$src")"
          if ! cmp -s "$src" "$dst" 2>/dev/null; then
            if ! run install -d "$dir" 2>/dev/null || ! run install -m 644 "$src" "$dst" 2>/dev/null; then
              warnEcho "Could not write to the macSKK container. Grant Full Disk Access to your terminal, or copy $src into $dir from Finder."
            fi
          fi
        done
      else
        verboseEcho "macSKK container not found; skipping dictionary install"
      fi
    '';
  };
}
