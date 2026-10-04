{ lib, pkgs, ... }:

{
  home.file.".claude/CLAUDE.md".source = ../../config/.claude/CLAUDE.md;
  home.file.".claude/settings.json".source = ../../config/.claude/settings.json;
  home.file.".claude/statusline.sh".source = ../../config/.claude/statusline.sh;
  home.file.".claude/notify.sh".source = ../../config/.claude/notify.sh;
  home.file.".claude/tmux_pane.sh".source = ../../config/.claude/tmux_pane.sh;
  home.file.".claude/skills".source = ../../config/.claude/skills;

  home.activation.claudeGlobalConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.claude.json"
    if [ -f "$config" ]; then
      tmp="$(mktemp)"
      ${pkgs.jq}/bin/jq '.diffSidebarOpen = false' "$config" > "$tmp" && run cp "$tmp" "$config"
      rm -f "$tmp"
    fi
  '';
}
