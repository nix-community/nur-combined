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
      environment.systemPackages = [(
        pkgs.writeShellScriptBin "openconnect" ''
           ${pkgs.openconnect}/bin/openconnect --background \
              --script "${pkgs.vpn-slice}/bin/vpn-slice --prevent-idle-timeout msk-vdi-t005.mos.renins.com --no-host-names --no-ns-hosts" \
              --interface job \
              --user "ALukyanov" \
              --authgroup "xFA" \
              --useragent "Cisco AnyConnect VPN Agent for Windows 4.8.03036" \
              --local-hostname "DESKTOP-DS0VFGI" \
              --os=win \
              vpn.renins.ru
        ''
      )];
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';

      #services.davmail.enable = true;
      services.davmail.url = "https://sync2.renins.com/ews/exchange.asmx";
      services.davmail.config = {
        davmail.defaultDomain = "mos.renins.com";
        davmail.allowRemote = true;
      };
    })
  ];
}
