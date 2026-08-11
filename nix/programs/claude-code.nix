{ pkgs, lib, ... }:

{
  home.file.".claude/CLAUDE.md".source = ../../config/.claude/CLAUDE.md;
  home.file.".claude/statusline.sh".source = ../../config/.claude/statusline.sh;
  home.file.".claude/skills".source = ../../config/.claude/skills;

  # settings.json は `claude plugin install` 等が実行時に書き込むため、
  # symlink ではなく初回のみコピーする書き込み可能ファイルとして配置する。
  # dotfiles 側の変更を反映するには ~/.claude/settings.json を削除してから make nix を再実行する。
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.claude/settings.json" ]; then
      run install -m644 ${../../config/.claude/settings.json} "$HOME/.claude/settings.json"
    fi
  '';
}
