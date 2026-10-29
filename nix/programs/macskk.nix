{ config, lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.macskkDictionaries = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      container="${config.home.homeDirectory}/Library/Containers/net.mtgto.inputmethod.macSKK/Data"
      if [ -d "$container" ]; then
        dir="$container/Documents/Dictionaries"
        src="${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
        run mkdir -p "$dir"
        if ! cmp -s "$src" "$dir/SKK-JISYO.L"; then
          run install -m 644 "$src" "$dir/SKK-JISYO.L"
        fi
      else
        verboseEcho "macSKK container not found; skipping dictionary install"
      fi
    '';
  };
}
