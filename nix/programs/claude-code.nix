{ lib, pkgs, ... }:

let
  jq = "${pkgs.jq}/bin/jq";
  settings = ../../config/.claude/settings.json;
in
{
  home.file.".claude/CLAUDE.md".source = ../../config/.claude/CLAUDE.md;
  home.file.".claude/statusline.sh".source = ../../config/.claude/statusline.sh;
  home.file.".claude/notify.sh".source = ../../config/.claude/notify.sh;
  home.file.".claude/skills".source = ../../config/.claude/skills;

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    target="$HOME/.claude/settings.json"
    preserved='{}'
    if [ -f "$target" ] && [ ! -L "$target" ]; then
      preserved=$(${jq} '{voice, voiceEnabled} | with_entries(select(.value != null))' "$target")
    fi
    tmp=$(mktemp)
    ${jq} --argjson preserved "$preserved" '. + $preserved' ${settings} > "$tmp"
    run mkdir -p "$HOME/.claude"
    run rm -f "$target"
    run install -m 644 "$tmp" "$target"
    rm -f "$tmp"
  '';
}
