{
  pkgs,
  config,
  inputs',
  lib,
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
      default = "0.0.0.0:8084";
    };
    home = mkOption {
      type = types.str;
      default = "/home/seed/.radicle";
    };
    package = mkPackageOption inputs'.radicle.packages "radicle-full" { };
    envFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };
  config = mkIf cfg.enable {
    users.users.seed = {
      description = "radicle seed user";
      isNormalUser = true;
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
        User = "seed";
        Group = "seed";
        ExecStart = "${cfg.package}/bin/radicle-node --listen ${cfg.listen} --force";
        Environment = [
          "RAD_HOME=${cfg.home}"
          "RUST_BACKTRACE=1"
          "RUST_LOG=info"
        ];
        EnvironmentFile = cfg.envFile;
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
      description = "Radicle HTTP Daemon";
      path = [ pkgs.git ];

      serviceConfig = {
        User = "seed";
        Group = "seed";
        ExecStart = "${cfg.package}/bin/radicle-httpd --listen ${cfg.httpListen}";
        Environment = [
          "RAD_HOME=${cfg.home}"
          "RUST_BACKTRACE=1"
          "RUST_LOG=info"
        ];
        KillMode = "process";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}
