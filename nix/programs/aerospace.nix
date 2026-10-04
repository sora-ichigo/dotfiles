{ lib, ... }:

{
  home.file.".config/aerospace/aerospace.toml".source = ../../config/.config/aerospace/aerospace.toml;
  home.file.".config/aerospace/arrange.sh".source = ../../config/.config/aerospace/arrange.sh;

  home.activation.reloadAerospace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x /opt/homebrew/bin/aerospace ]; then
      run /opt/homebrew/bin/aerospace reload-config 2>/dev/null || true
    fi
  '';
}
