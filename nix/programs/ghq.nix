{ config, ... }:

{
  home.file."ghq/github.com/sora-ichigo/wantedly".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.obsidian/igsr5/10_wantedly";
  home.file."ghq/github.com/sora-ichigo/personal".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.obsidian/igsr5/12_personal";
}
