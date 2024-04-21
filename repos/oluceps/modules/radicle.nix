{
  pkgs,
  config,
  inputs',
  lib,
  user,
  ...
}:
let
  cfg = config.services.radicle;
  inherit (lib)
    mkOption
    mkPackageOption
    types
    mkIf
    mkEnableOption
    ;
in
{
  options.services.radicle = {
    enable = mkEnableOption "enable radicle seed node";
    listen = mkOption {
      type = types.str;
      default = "0.0.0.0:8776";
    };
    httpListen = mkOption {
      type = types.str;
      default = "127.0.0.1:8084";
    };
    package = mkPackageOption inputs'.radicle.packages "radicle-full" { };
    envFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };
  config = mkIf cfg.enable {
    users.users.seed = {
      isSystemUser = true;
      group = "seed";
    };
    users.groups.seed = { };

    systemd.services.radicle-node = {
      requires = [ "network-online.target" ];
      after = [
        "network-online.target"
        "network.target"
      ];
      wantedBy = [ "multi-user.target" ];
      description = "Radicle Node";

      serviceConfig = {
        User = user;
        ExecStart = "${cfg.package}/bin/radicle-node --listen ${cfg.listen} --force";
        Environment = [
          "RAD_HOME=/home/${user}/.local/share/radicle"
          "RUST_BACKTRACE=1"
          "RUST_LOG=info"
        ];
        EnvironmentFile = cfg.envFile;
        # StateDirectory = "radicle";
        KillMode = "process";
        Restart = "always";
        RestartSec = 3;
      };
    };

    systemd.services.radicle-httpd = {
      requires = [ "network-online.target" ];
      after = [
        "network-online.target"
        "network.target"
      ];
      wantedBy = [ "multi-user.target" ];
      description = "Radicle httpd";
      path = [ pkgs.git ];

      serviceConfig = {
        User = user;
        ExecStart = "${cfg.package}/bin/radicle-httpd --listen ${cfg.httpListen}";
        Environment = [
          "RAD_HOME=/home/${user}/.local/share/radicle"
          "RUST_BACKTRACE=1"
          "RUST_LOG=info"
        ];
        EnvironmentFile = cfg.envFile;
        # StateDirectory = "radicle";
        KillMode = "process";
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}
