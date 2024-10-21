{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.services.rustypaste;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.rustypaste = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rustypaste;
    };
    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.rustypaste = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "pastebin";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/rustypaste";
        StateDirectory = "rustypaste";
        Environment = "CONFIG=${settingsFormat.generate "config.toml" cfg.settings}";
        Restart = "on-failure";

        ProtectSystem = "full";
        ProtectHome = "tmpfs";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_NETLINK"
          "AF_UNIX"
        ];
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
      };
    };
  };
}
