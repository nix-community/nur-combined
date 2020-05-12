{ config, lib, pkgs, ... }:

let
  cfg = config.services.onedrive;

  # Replicate a string 'n' times with spaces in between
  replicateStr = n: str: builtins.concatStringsSep " " (builtins.genList (lib.const str) n);

in {
  options.services.onedrive = {
    enable = lib.mkEnableOption "Enable OneDrive service";

    monitorInterval = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Number of seconds by which each sync operation is undertaken when idle under monitor mode";
    };

    verbosity = lib.mkOption {
      type = lib.types.ints.between 0 2;
      default = 1;
      description = "The amount of detail to log";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.onedrive ];

    systemd.user.services.onedrive-sync = {
      description = "OneDrive Free Client";
      documentation = [ "https://github.com/abraunegg/onedrive" ];

      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.onedrive}/bin/onedrive --monitor \
          ${replicateStr cfg.verbosity " --verbose"} \
          --confdir=%h/.config/onedrive \
          ${lib.optionalString (cfg.monitorInterval != null) "--monitor-interval ${toString cfg.monitorInterval}"}
        '';
        Restart = "on-failure";
        RestartSec = 3;
        RestartPreventExitStatus = 3;
      };
    };
  };
}
