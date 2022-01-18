{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.job;
in {
  options.services.job = {
    enablePrograms = mkEnableOption ''
      Programs for job
    '';
    enableVpn = mkEnableOption ''
      VPN client
    '';
  };

  config = mkMerge [
    (mkIf cfg.enablePrograms {
      # remember Skype password
      services.gnome.gnome-keyring.enable = true;
      environment = {
        systemPackages = with pkgs; [
          gnome3.networkmanagerapplet
          remmina
          skype zoom-us mattermost-desktop
        ];
      };
    })
    (mkIf cfg.enableVpn {
      systemd.services.jobvpn = {
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      description = "Job VPN";
      path = with pkgs; [ openconnect vpn-slice coreutils iproute2 iptables ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "jobvpn" ''
          cat /etc/openconnect.conf | \
          openconnect \
            --script "vpn-slice msk-vdi-t005.mos.renins.com" \
            --interface job0 \
            --user "ALukyanov" \
            --passwd-on-stdin \
            --authgroup "2_FULL_ACCESS" \
            --useragent "Cisco AnyConnect VPN Agent for Windows 4.8.03036" \
            --local-hostname "DESKTOP-DS0VFGI" \
            --os=win \
            vpn-yar.renins.ru
          '';
        };
      };
      environment.etc.hosts.mode = "0644";
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job0 -j MASQUERADE
      '';
    })
  ];
}
