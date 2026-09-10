{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.codex ];

  home.file.".codex/AGENTS.md".source = ../../config/.codex/AGENTS.md;
  home.file.".codex/prompts".source = ../../config/.codex/prompts;

  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codexConfig="$HOME/.codex/config.toml"

    codexProjects=""
    if [ -f "$codexConfig" ]; then
      codexProjects="$(${pkgs.gawk}/bin/awk '/^\[/ { keep = ($0 ~ /^\[projects[.\]]/) } keep' "$codexConfig")"
    fi

    $DRY_RUN_CMD mkdir -p "$HOME/.codex"
    $DRY_RUN_CMD rm -f "$codexConfig"
    $DRY_RUN_CMD install -m 600 ${../../config/.codex/config.toml} "$codexConfig"

    if [ -n "$codexProjects" ]; then
      printf '\n%s\n' "$codexProjects" | $DRY_RUN_CMD ${pkgs.coreutils}/bin/tee -a "$codexConfig" > /dev/null
    fi
  '';
}
