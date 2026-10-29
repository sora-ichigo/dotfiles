{ config, lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.macskkDictionaries = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      container="${config.home.homeDirectory}/Library/Containers/net.mtgto.inputmethod.macSKK/Data"
      if [ -d "$container" ]; then
        dir="$container/Documents/Dictionaries"
        src="${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
        if ! cmp -s "$src" "$dir/SKK-JISYO.L" 2>/dev/null; then
          if ! run install -d "$dir" 2>/dev/null || ! run install -m 644 "$src" "$dir/SKK-JISYO.L" 2>/dev/null; then
            warnEcho "Could not write to the macSKK container. Grant Full Disk Access to your terminal, or copy $src into $dir from Finder."
          fi
        fi
      else
        verboseEcho "macSKK container not found; skipping dictionary install"
      fi
    '';
  };
}
