{
  pkgs,
  config,
  inputs,
  reIf,
  ...
}:
reIf {
  vaultix.templates.dae-sep = {
    name = "merged.dae";
    content = ''
      global {
          tproxy_port: 12345
          log_level: info
          tcp_check_url: 'https://www.apple.com/library/test/success.html'
          udp_check_dns: 'dns.google.com:53,114.114.114.114:53,2001:4860:4860::8888,1.1.1.1:53'
          check_interval: 20s
          check_tolerance: 100ms
          wan_interface: auto
          allow_insecure: false
          dial_mode: domain
          disable_waiting_network: false
          auto_config_kernel_parameter: true
          enable_local_tcp_fast_redirect: true
          sniffing_timeout: 100ms
          tls_implementation: utls
          utls_imitate: chrome_auto
          lan_interface: podman0,podman1
      }
      ${config.vaultix.placeholder.dae}
      routing {
          pname(systemd-networkd, systemd-resolved, smartdns,
                dnsproxy, coredns, mosdns, naive, hysteria, tuic-client, sing-box, juicity, mosproxy) -> must_direct
          pname(prometheus) -> direct

          pname(conduit, arti) -> all
          pname(misskey) -> all
          dip(9.9.9.9) -> direct
          dip(1.1.1.1, 8.8.8.8, 1.0.0.1, 8.8.4.4) -> all
          dip(224.0.0.0/3, 'ff00::/8', 10.0.0.0/8) -> direct

          #ipversion(6) && !dip(geoip:CN) -> v6

          domain(geosite:google-gemini,openai,geosite:category-ai-chat-!cn,cloudflare) -> v6

          domain(geosite:cn) -> direct
          dip(geoip:private,geoip:cn) -> direct
          domain(suffix:'api.atuin.nyaw.xyz') -> all

          domain(suffix: '4.ip.skk.moe') -> all
          domain(suffix: '2.ip.skk.moe') -> direct

          domain(geosite:github) -> rand

          fallback: all
      }
    '';
  };
  services.dae = {
    enable = true;
    disableTxChecksumIpGeneric = false;
    configFile = config.vaultix.templates.dae-sep.path;
    package = pkgs.dae-unstable;
    assetsPath = toString (
      pkgs.symlinkJoin {
        name = "dae-assets-nixy";
        paths = [
          "${inputs.nixyDomains}/assets"
          "${pkgs.v2ray-geoip}/share/v2ray"
        ];
      }
    );

    openFirewall = {
      enable = true;
      port = 12345;
    };
  };
}
