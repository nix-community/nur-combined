{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.seaweedfs;

in
{
  options.services.seaweedfs = {
    enable = mkEnableOption "seaweedfs Storage";

    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    package = mkPackageOption pkgs "seaweedfs" { };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users.users.seaweedfs = {
      group = "seaweedfs";
      isSystemUser = true;
    };
    users.groups.seaweedfs = { };

    systemd = lib.mkMerge [
      {
        services.seaweedfs = {
          description = "seaweedfs Object Storage";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${cfg.package}/bin/weed ${lib.concatStringsSep " " cfg.args}";
            ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
            Type = "simple";
            DynamicUser = true;
            SyslogIdentifier = "seaweedfs-master";
            LimitNOFILE = 65536;
          };
          environment = {
            WEED_MASTER_VOLUME_GROWTH_COPY_1 = "3";
            WEED_MASTER_VOLUME_GROWTH_COPY_2 = "3";
            WEED_MASTER_VOLUME_GROWTH_COPY_3 = "3";
            WEED_MASTER_VOLUME_GROWTH_COPY_OTHER = "3";
          };
        };
      }
    ];
  };
}
