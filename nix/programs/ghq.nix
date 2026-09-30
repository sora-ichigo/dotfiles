{ config, ... }:

{
  home.file."ghq/github.com/sora-ichigo/wantedly-performance-review".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.obsidian/igsr5/10_performance_review";
}
