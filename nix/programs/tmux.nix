{ pkgs, lib, ... }:

{
  home.file.".config/tmux/tmux.conf".source = ../../config/.config/tmux/tmux.conf;
  home.file.".config/tmux/scripts".source = ../../config/.config/tmux/scripts;

  home.activation.installTPM = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
      run ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
  '';

  home.packages = [ pkgs.tmux pkgs.sesh ];
}
