{
  pkgs,
  config,
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
    home = mkOption {
      type = types.str;
      default = "/home/seed/.radicle";
    };
    package = mkPackageOption pkgs "radicle";
  };
  config = mkIf cfg.enable {
    users.users.seed = {
      description = "radicle seed user";
      isNormalUser = true;
      group = "seed";
    };
    users.groups.seed = { };

    systemd.services.radicle = {
      requires = [ "network-online.target" ];
      after = [
        "network-online.target"
        "network.target"
      ];
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

        KillMode = "process";
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}
