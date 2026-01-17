{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh &> /dev/null; then
        exec zsh
      fi
    '';
  };
}
