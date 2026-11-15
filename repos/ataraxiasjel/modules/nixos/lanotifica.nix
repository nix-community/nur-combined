{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.lanotifica;
in
{
  options.services.lanotifica = {
    enable = mkEnableOption "LaNotifica, the Android notification forwarder for Linux desktops";
    package = mkPackageOption pkgs "lanotifica" { };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the default LaNotifica server port (TCP 19420, UDP 5353) in the firewall.
        If you change the port in the application config (~/.config/lanotifica/config.json),
        open the new port manually instead.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 19420 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 5353 ];

    systemd.user.services.lanotifica = {
      description = "LaNotifica - Android notification forwarder";
      documentation = [ "https://github.com/alessandrolattao/lanotifica" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package}";
        Restart = "on-failure";
        RestartSec = 5;

        LockPersonality = true;
        NoNewPrivileges = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
      };
    };
  };
}
