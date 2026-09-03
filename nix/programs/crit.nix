{ critPackage, ... }:

{
  home.packages = [ critPackage ];

  home.file.".crit.config.json".source = ../../config/.crit.config.json;
}
