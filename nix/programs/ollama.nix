{ config, pkgs, lib, ... }:

let
  logDir = "${config.home.homeDirectory}/.local/state/ollama";
in
{
  home.packages = [ pkgs.ollama ];

  home.activation.ollamaDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${logDir}
  '';

  launchd.agents.ollama = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        OLLAMA_HOST = "127.0.0.1:11434";
      };
      StandardOutPath = "${logDir}/ollama.log";
      StandardErrorPath = "${logDir}/ollama.log";
    };
  };
}
