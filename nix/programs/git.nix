{ pkgs, ... }:

{
  home.packages = [ pkgs.git ];

  home.file.".gitconfig".source = ../../config/.gitconfig;
  home.file.".gitignore_global".source = ../../config/.gitignore_global;
  home.file.".git_template".source = ../../config/.git_template;
}
