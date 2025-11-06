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
    package = inputs'.dae.packages.dae-next;
    # package = inputs'.dae.packages.dae-unstable;
    config =
      let
        notEihort = lib.optionalString (!(config.networking.hostName == "eihort"));
      in
      ''
        include {
            secret.dae
        }
        global {
            tproxy_port: 12345
            log_level: info
            check_interval: 30s
            check_tolerance: 50ms
            wan_interface: auto
            allow_insecure: false
            # metrics_addr: '[::]:8087'
            pprof_port: 9901
            sniff_verify_mode: strict
            reroute_mode: force
            disable_waiting_network: false
            auto_config_kernel_parameter: true
            enable_local_tcp_fast_redirect: true
            # sniffing_timeout: 50ms
            tls_implementation: utls
            utls_imitate: chrome_auto
            lan_interface: podman0,podman1
            mptcp: true
            tls_fragment_length: '50-100'
            tls_fragment_interval: '10-20'
            fallback_resolver: '8.8.8.8:53'
        }

        dns {
            ipversion_prefer: 4
            upstream {
               ${notEihort "local: 'udp://[2409:8034:2000::1]'"}
                googledns: 'tcp+udp://dns.google'
                pol: 'quic://dns.alidns.com'
            }
            routing {
                request {
                    # qname(ext:"geosite:category-ads-all") -> reject
                    ${notEihort "qname(geosite:cn) -> local"}
                    fallback: googledns
                }
                response {
                    upstream(pol) -> accept
                    !qname(geosite:cn) && ip(geoip:private) -> pol
                    fallback: accept
                }
            }
        }

        routing {
            pname(bird, systemd-networkd, smartdns,
                  dnsproxy, coredns, mosdns, naive, hysteria, tuic-client, sing-box, juicity, mosproxy) -> must_direct

            pname(prometheus,ssh) -> direct
            pname(chatmcp) -> ai

            pname(Misskey, conduit, tuwunel, conduwuit, .mautrix-telegr, arti, .synapse_homese) -> all
            dip(9.9.9.9) -> direct
            dip(1.1.1.1, 8.8.8.8, 1.0.0.1, 8.8.4.4) -> all
            dip(224.0.0.0/3, 'ff00::/8', 10.0.0.0/8, 'fd00::/8') -> direct


            domain(suffix:migadu.com) -> all
            dport(465) -> all
            domain(geosite:google-gemini,google,openai,geosite:category-ai-chat-!cn,cloudflare) -> ai
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
                suffix: apple-relay.apple.com,
                suffix: google.com,
                domain: ai.google.dev,
                domain: alkalimakersuite-pa.clients6.google.com,
                domain: makersuite.google.com,
                domain: bard.google.com,
                domain: deepmind.com,
                domain: deepmind.google,
                domain: gemini.google.com,
                domain: generativeai.google,
                domain: proactivebackend-pa.googleapis.com,
                domain: apis.google.com) -> ai

            # k is the machine, use dae, and use v6 static route forward
            ipversion(6) && !dip(geoip:CN) -> ${
              if config.networking.hostName == "kaambl" then "direct" else "v6"
            }
            domain(${
              lib.concatMapStringsSep "," (n: "suffix: ${n}.nyaw.xyz") (builtins.attrNames lib.data.node)
            }) -> direct

            ${notEihort ''
              domain(geosite:cn) -> direct
              dip(geoip:cn) -> direct
            ''}
            dip(geoip:private) -> direct

            domain(suffix:'api.atuin.nyaw.xyz') -> all

            domain(suffix: '4.ip.skk.moe') -> all
            domain(suffix: '2.ip.skk.moe') -> direct

            fallback: all
        }
      '';
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
