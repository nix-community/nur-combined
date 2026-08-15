{ lib, pkgs, config, ... }:

let
  cfg = config.programs.pvpn;
  pkgs-set = pkgs.callPackage ./../.. { };
  inherit (lib) mkIf;
in
{
  options.programs.pvpn = {
    enable = lib.mkEnableOption "pvpn";
    package = lib.mkPackageOption pkgs-set "pvpn" { nullable = true; };

    users = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Usernames to add to the "pvpn" group, which is needed,
        to launch the pVPN daemon.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf (cfg.package != null) [ cfg.package ];

    users.groups.pvpn.members = cfg.users;

    systemd.services.pvpnd = {
      description = "pVPN Daemon - Proton VPN Connection Manager";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Environment = "HOME=/var/lib/pvpn";
        ExecStart = lib.getExe' cfg.package "pvpnd";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "pvpn";
        StateDirectory = "pvpn";
        StateDirectoryMode = 0700;
        ReadWritePaths = "/run/pvpn /etc/resolv.conf /etc/pvpn /var/lib/pvpn";
        ProtectHome = true;
        PrivateTmp = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
