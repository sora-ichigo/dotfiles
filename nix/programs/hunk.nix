{ pkgs, ... }:

let
  # nixpkgs の hunk は 0.18.0 で止まっている（bot の自動更新が postPatch の
  # パターン不一致で失敗している）。extension API v5 を要求する extension を
  # 使うため 0.19.0 の derivation を自前で持つ。nixpkgs が追いついたら削除する
  # https://github.com/NixOS/nixpkgs/pull/554129
  hunk = pkgs.callPackage ../pkgs/hunk/package.nix { };

  # diff の内容を less 風に検索する extension。依存は devDependencies だけなので
  # checkout をそのまま置けば動く
  hunk-less-search = pkgs.fetchFromGitHub {
    owner = "elucid";
    repo = "hunk-less-search";
    rev = "787a6d4a5d6c075740d02bb71d45d0aba707d204";
    hash = "sha256-JOV/f148SpfFDGp1FvXSG26J6zLn4tMqAAmGgMdyS3Y=";
  };
in
{
  home.packages = [ hunk ];

  home.file.".config/hunk/config.toml".source = ../../config/.config/hunk/config.toml;
  home.file.".config/hunk/extensions/hunk-less-search".source = hunk-less-search;
}
