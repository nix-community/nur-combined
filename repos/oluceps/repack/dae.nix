{
  pkgs,
  lib,
  config,
  inputs,
  inputs',
  reIf,
  ...
}:
reIf {
  environment.etc."dae/secret.dae".source = config.vaultix.secrets.dae.path;

  # services.daed.enable = true;
  services.dae = {
    enable = true;
    disableTxChecksumIpGeneric = false;
    config = ''
      include {
          secret.dae
      }
      global {
          tproxy_port: 12345
          log_level: info
          # tcp_check_url: 'https://www.apple.com/library/test/success.html'
          tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111'
          udp_check_dns: '8.8.8.8:53,114.114.114.114:53,2001:4860:4860::8888,1.1.1.1:53'
          check_interval: 30s
          check_tolerance: 50ms
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
          mptcp: true
      }
      routing {
          pname(bird, systemd-resolved, smartdns,
                dnsproxy, coredns, mosdns, naive, hysteria, tuic-client, sing-box, juicity, mosproxy) -> must_direct

          pname(prometheus, systemd-networkd) -> direct
          pname(chatmcp) -> ai

          pname(Misskey, conduit, tuwunel, conduwuit, .mautrix-telegr, arti) -> all
          dip(9.9.9.9) -> direct
          dip(1.1.1.1, 8.8.8.8, 1.0.0.1, 8.8.4.4) -> all
          dip(224.0.0.0/3, 'ff00::/8', 10.0.0.0/8, 'fd00::/8') -> direct

          # k is the machine, use dae, and use v6 static route forward
          ipversion(6) && !dip(geoip:CN) -> ${
            if config.networking.hostName == "kaambl" then "direct" else "v6"
          }

          domain(suffix:migadu.com) -> all
          dport(465) -> all
          domain(geosite:google-gemini,openai,geosite:category-ai-chat-!cn,cloudflare) -> v6
          domain(suffix: copilot.microsoft.com,
              suffix: gateway-copilot.bingviz.microsoftapp.net,
              suffix: mobile.events.data.microsoft.com,
              suffix: graph.microsoft.com,
              suffix: analytics.adjust.com,
              suffix: analytics.adjust.net.in,
              suffix: api.revenuecat.com,
              suffix: t-msedge.net,
              suffix: cloudapp.azure.com,
              suffix: browser-intake-datadoghq.com,
              suffix: in.appcenter.ms,
              suffix: guzzoni.apple.com,
              suffix: smoot.apple.com,
              suffix: apple-relay.cloudflare.com,
              suffix: apple-relay.fastly-edge.com,
              suffix: cp4.cloudflare.com,
              suffix: apple-relay.apple.com) -> v6

          domain(${
            lib.concatMapStringsSep "," (n: "suffix: ${n}.nyaw.xyz") (builtins.attrNames lib.data.node)
          }) -> direct

          dip(${
            lib.concatStringsSep "," (
              map (i: "\"${i.addr}\"") (builtins.attrValues (lib.filterAttrs (k: v: v.censor) lib.data.node))
            )
          }) -> direct

          domain(geosite:cn) -> direct
          dip(geoip:private,geoip:cn) -> direct
          domain(suffix:'api.atuin.nyaw.xyz') -> all

          domain(suffix: '4.ip.skk.moe') -> all
          domain(suffix: '2.ip.skk.moe') -> direct

          domain(geosite:github) -> rand

          fallback: all
      }
    '';
    package = inputs'.dae.packages.dae-unstable;
    # package = inputs'.dae.packages.dae-pr-748-fix;
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
