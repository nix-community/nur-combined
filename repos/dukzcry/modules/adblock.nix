{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.adblock;
  serviceOptions = pkgs.nur.repos.dukzcry.lib.systemd.default // {
    PrivateDevices = true;
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    Group = "dnsmasq";
    StateDirectory = "adblock";
  };
in {
  options.services.adblock = {
    enable = mkEnableOption "adblocking via DNS";
    OnCalendar = mkOption {
      type = types.str;
      default = "weekly";
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq.enable = true;
    services.dnsmasq.extraConfig = ''
      conf-file=/var/lib/adblock/dnsmasq/dnsmasq.blacklist.txt
    '';
    systemd.timers.adblock = {
      timerConfig = {
        inherit (cfg) OnCalendar;
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services.adblock = {
      description = "Adblock DNS script";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "adblock.sh" ''
          set -e
          cd /var/lib/adblock
          ${pkgs.nur.repos.dukzcry.gitupdate}/bin/gitupdate
          systemctl restart dnsmasq
        '';
      } // serviceOptions;
    };
  };
}
