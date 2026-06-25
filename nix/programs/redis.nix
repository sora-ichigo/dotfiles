{ config, pkgs, lib, ... }:

let
  dataDir = "${config.home.homeDirectory}/.local/share/redis";
  logDir = "${config.home.homeDirectory}/.local/state/redis";

  # 開発用キャッシュ用途のため永続化は無効化する。
  # RDB/AOF を切ることで bgsave 失敗による書き込み停止 (MISCONF) を原理的に防ぐ。
  # dir も絶対パスで固定し、起動ディレクトリ (cwd) に依存しないようにする。
  redisConf = pkgs.writeText "redis.conf" ''
    port 6379
    bind 127.0.0.1
    dir ${dataDir}
    save ""
    appendonly no
  '';
in
{
  home.activation.redisDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${dataDir} ${logDir}
  '';

  launchd.agents.redis = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.redis}/bin/redis-server" "${redisConf}" ];
      RunAtLoad = true;
      KeepAlive = true;
      WorkingDirectory = dataDir;
      StandardOutPath = "${logDir}/redis.log";
      StandardErrorPath = "${logDir}/redis.log";
    };
  };
}
