{ pkgs, ... }:

{
  home.packages = [ pkgs.hunk ];

  home.file.".config/hunk/config.toml".source = ../../config/.config/hunk/config.toml;
  home.file.".config/hunk/extensions/notes-backup.ts".source = ../../config/.config/hunk/extensions/notes-backup.ts;
}
