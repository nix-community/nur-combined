{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.dae = {
    enable = true;
    configFile = lib.mkIf config.services.dae.enable config.sops.templates."config.dae".path;
    assetsPath = "${pkgs.rules.combined."elysias123/geosite"}/share/v2ray";
    openFirewall = {
      enable = true;
      # Must match tproxy_port in config.dae.
      port = 12345;
    };
  };

  sops = lib.mkIf config.services.dae.enable {
    secrets."proxy/sub_store" = { };
    templates."config.dae" = {
      restartUnits = [ "dae.service" ];
      content =
        let
          sub_store = config.sops.placeholder."proxy/sub_store";
        in
        ''
          global {
            lan_interface: bond0
            wan_interface: bond0
            tproxy_port: 12345
            tproxy_port_protect: true
            log_level: info
            allow_insecure: false
            auto_config_kernel_parameter: true
            dial_mode: domain
            bandwidth_max_tx: '100 mbps'
            bandwidth_max_rx: '400 mbps'
          }

          subscription {
            flowercloud: '${sub_store}/download/flowercloud?target=URI'
            mesl: '${sub_store}/download/mesl?target=URI'
          }

          group {
            proxy {
              policy: min_moving_avg
              filter: subtag(flowercloud) && name(keyword: '🇭🇰')
            }
            jp {
              policy: min_moving_avg
              filter: subtag(flowercloud) && name(keyword: '🇯🇵')
            }
          }

          dns {
            upstream {
              router: 'udp://192.168.88.254:53'
              alidns: 'udp://223.5.5.5:53'
              googledns: 'tcp+udp://8.8.8.8:53'
            }
            routing {
              request {
                qname(suffix: lan) -> router
                qname(geosite: cn) -> router
                fallback: googledns
              }
            }
          }

          routing {
            pname(NetworkManager, systemd-resolved, dnsmasq) -> must_direct
            pname(smbd) -> must_direct
            pname(snell-server) -> must_direct
            pname(tailscale, tailscaled) -> must_direct
            pname(mihomo, sing-box) -> must_direct
            pname(mtr, nexttrace) -> must_direct
            pname(qbittorrent, qbittorrent-nox, qbittorrent-cli) -> must_direct

            # OpenWrt
            mac("00:48:54:20:b7:ff") -> must_direct
            sip("192.168.88.100") -> must_direct

            l4proto(udp) && dport(443) -> block

            domain(geosite:"category-ads-all") -> block
            domain(geosite:"category-ai-!cn") -> jp
            domain(softwaredownload.futunn.com) -> direct
            domain(geosite:cn) -> direct

            dip(geoip:private, 100.64.0.0/10, 198.18.0.0/15, 224.0.0.0/4, 'ff00::/8') -> direct
            dip(geoip:cn) -> direct
            fallback: proxy
          }
        '';
    };
  };
}
