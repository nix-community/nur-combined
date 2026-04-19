{
  inputs,
  ...
}:
{
  flake.modules.nixos.dae =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [ inputs.dae.nixosModules.dae ];
      vaultix.secrets.dae = {
        owner = "root";
        mode = "400";
      };
      environment.etc."dae/secret.dae" = {
        source = config.vaultix.secrets.dae.path;
        # mode = "0400";
      };

      networking.firewall.trustedInterfaces = [ "dae0" ];

      services.dae = {
        enable = true;
        disableTxChecksumIpGeneric = false;
        package = inputs.dae.packages.${pkgs.stdenv.hostPlatform.system}.dae-unstable;
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
                 pprof_port: 9901
                 dial_mode: domain
                 disable_waiting_network: false
                 auto_config_kernel_parameter: true
                 tls_implementation: utls
                 utls_imitate: ios_auto
                 lan_interface: br0,podman0,podman1,podman2,podman3,docker0
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
                       dnsproxy, coredns, mosdns, naive,
                       hysteria, tuic-client, sing-box,
                       juicity, mosproxy, yggdrasil,
                       zerotier-one, cloudflared) -> must_direct

                 pname(prometheus, ssh) -> direct


                 pname(Misskey, conduit, tuwunel, conduwuit,
                       .mautrix-telegr, arti, .synapse_homese) -> all

                 dip(1.1.1.1, 8.8.8.8, 1.0.0.1, 8.8.4.4) -> all
                 dip(224.0.0.0/3, 'ff00::/8', 10.0.0.0/8, 'fd00::/8', '200::/7') -> direct

                 domain(geosite:anthropic) -> anthropic
                 pname(claude) -> anthropic

                 domain(suffix:migadu.com) -> all
                 dport(465) -> v6

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

                 ipversion(6) && !dip(geoip:CN) -> ${
                   if config.networking.hostName == "kaambl" then "direct" else "v6"
                 }
                 domain(${
                   lib.concatMapStringsSep "," (n: "suffix: ${n}.nyaw.xyz") (builtins.attrNames config.data.node)
                 }) -> direct
                 ${notEihort ''
                   domain(geosite:cn) -> direct
                   dip(geoip:cn) -> direct
                 ''}
                 dip(geoip:private) -> direct

                 domain(suffix:'api.atuin.nyaw.xyz') -> all
                 domain(full:'box.nyaw.xyz') -> v6

                 domain(suffix: '4.ip.skk.moe') -> all
                 domain(suffix: '2.ip.skk.moe') -> direct
                 domain(suffix: 'exhentai.org') -> ex

                 fallback: all
             }
          '';
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
    };
}
