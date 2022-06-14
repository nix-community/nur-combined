{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.job;
in {
  options.services.job = {
    client = mkEnableOption ''
      Programs for job
    '';
    server = mkEnableOption ''
      Services for job
    '';
  };

  config = mkMerge [
    (mkIf cfg.client {
      # remember Skype password
      services.gnome.gnome-keyring.enable = true;
      environment = {
        systemPackages = with pkgs; [
          networkmanagerapplet remmina
          skypeforlinux zoom-us mattermost-desktop
        ];
      };
    })
    (mkIf cfg.server {
      systemd.services.jobvpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        description = "Job VPN";
        path = with pkgs; [ openconnect vpn-slice coreutils iproute2 iptables ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "jobvpn" ''
            cat /etc/openconnect.conf | \
            openconnect \
              --script "vpn-slice --prevent-idle-timeout msk-vdi-t005.mos.renins.com" \
              --interface job \
              --user "ALukyanov" \
              --passwd-on-stdin \
              --authgroup "2_FULL_ACCESS" \
              --useragent "Cisco AnyConnect VPN Agent for Windows 4.8.03036" \
              --local-hostname "DESKTOP-DS0VFGI" \
              --os=win \
              vpn-yar.renins.ru
            '';
          Restart="on-failure";
        };
      };
      environment.etc.hosts.mode = "0644";
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';

      services.davmail.enable = true;
      services.davmail.url = "https://sync2.renins.com/ews/exchange.asmx";
      services.davmail.config = {
        davmail.defaultDomain = "mos.renins.com";
        davmail.allowRemote = true;
      };
    })
  ];
}
