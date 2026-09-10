{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.gemini-cli ];

  home.file.".gemini/GEMINI.md".source = ../../config/.gemini/GEMINI.md;

  home.file.".gemini/skills".source = ../../config/.claude/skills;

  home.activation.geminiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    geminiSettings="$HOME/.gemini/settings.json"
    geminiDeclared=${../../config/.gemini/settings.json}

    $DRY_RUN_CMD mkdir -p "$HOME/.gemini"

    if [ ! -f "$geminiSettings" ]; then
      $DRY_RUN_CMD install -m 600 "$geminiDeclared" "$geminiSettings"
    else
      merged="$(${pkgs.jq}/bin/jq -n \
        --slurpfile existing "$geminiSettings" \
        --slurpfile declared "$geminiDeclared" \
        '($existing[0] // {}) as $e | $declared[0] as $d | ($e * $d) | .mcpServers = $d.mcpServers')"
      printf '%s\n' "$merged" | $DRY_RUN_CMD ${pkgs.coreutils}/bin/tee "$geminiSettings" > /dev/null
      $DRY_RUN_CMD chmod 600 "$geminiSettings"
    fi
  '';
}
