{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.memos;
in
{
  disabledModules = [ "services/misc/memos.nix" ];
  options.services.memos = {
    enable = mkEnableOption "memos service";
    package = mkPackageOption pkgs "memos" { };
    instanceUrl = mkOption {
      type = types.str;
    };
    environmentFile = mkOption {
      type = types.either types.str types.path;
    };
    mode = mkOption {
      type = types.enum [
        "prod"
        "dev"
        "demo"
      ];
    };
    port = mkOption {
      type = types.port;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.memos = {
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
      ];
      description = "memos daemon";
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --mode ${cfg.mode} --port ${toString cfg.port} --instance-url ${cfg.instanceUrl}";
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";
      };
    };
  };
}
