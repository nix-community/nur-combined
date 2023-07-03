{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.job;
  vpn-slice = pkgs.vpn-slice.overrideAttrs (oldAttrs: rec {
    preConfigure = ''
      substituteInPlace vpn_slice/posix.py \
        --replace /etc/hosts /var/lib/dnsmasq/hosts/hosts
    '';
  });
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
      environment = {
        systemPackages = with pkgs; [
          networkmanagerapplet remmina
          skypeforlinux zoom-us mattermost-desktop
        ];
      };
      programs.evolution.plugins = [ pkgs.evolution-ews ];
    })
    (mkIf cfg.server {
      environment.systemPackages = [(
        pkgs.writeShellScriptBin "openconnect" ''
           ${pkgs.openconnect}/bin/openconnect \
              --background \
              --script "${vpn-slice}/bin/vpn-slice msk-vdi-t005.mos.renins.com test.iris.k8s.renins.com wiki.renins.com mytask.renins.com --prevent-idle-timeout" \
              --interface job \
              --user "ALukyanov" \
              --authgroup "xFA" \
              --useragent "Cisco AnyConnect VPN Agent for Windows 4.8.03036" \
              --version-string "4.8.03036" \
              --local-hostname "DESKTOP-DS0VFGI" \
              --os=win \
              vpn.renins.ru
        ''
      )];
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';
      services.dnsmasq.settings = {
        hostsdir = "/var/lib/dnsmasq/hosts";
        server = [ "/iris.k8s.renins.com/10.50.0.43" "/iris.k8s.renins.com/10.50.0.44" ];
        rebind-domain-ok = "iris.k8s.renins.com";
      };
      #services.davmail.enable = true;
      services.davmail.url = "https://sync2.renins.com/ews/exchange.asmx";
      services.davmail.config = {
        davmail.defaultDomain = "mos.renins.com";
        davmail.allowRemote = true;
      };
    })
  ];
}
