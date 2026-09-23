{
  flake.modules.nixos.bird =
    { config, lib, ... }:
    {
      options.bird = {
        baseConfig = lib.mkOption {
          type = lib.types.lines;
          readOnly = true;
          default = ''
            log syslog all;
            # debug protocols all;
            timeformat protocol iso long;

            router id 10.0.0.${toString ((config.fn.getThisNode).id + 1)};

            define HORTUS_OWNIP = ${config.fn.getIntraAddr};
            define HORTUS_PREFIX = fdcc::/16;
            define HORTUS_FIELD = [ fdcc::/16+ ];

            define DN42_ASN = 4242420291;
            define DN42_PREFIX = fdda:1965:1d5f::/48;
            define DN42_FIELD = [ fdda:1965:1d5f::/48+ ];
            define DN42_PREFIX_V4 = 172.22.105.160/27;
            define DN42_FIELD_V4 = [ 172.22.105.160/27+ ];
            define DN42_OWNIP = fdda:1965:1d5f::${toString ((config.fn.getThisNode).id + 1)};
            define DN42_OWNIP_V4 = 172.22.105.16${toString ((config.fn.getThisNode).id + 1)};

            protocol device {
              scan time 20;
            };
            protocol direct {
              ipv6;
              interface "anchor-*"; 
            }

            protocol static guard {
              ipv6;
              route HORTUS_PREFIX reject;
            }

            function in_hortus() -> bool {
              return net ~ HORTUS_FIELD;
            };

            filter to_hortus {
              if in_hortus() && (source = RTS_BABEL || source = RTS_DEVICE) then accept;
              if proto = "ext" then accept;
              reject;
            };

            filter to_kernel {
              case source {
                RTS_STATIC: {

                  if proto = "guard" then reject;

                  krt_prefsrc = HORTUS_OWNIP;
                  krt_metric = 512;
                  accept;
                }
                RTS_BABEL: {
                  krt_prefsrc = HORTUS_OWNIP;
                  krt_metric = 128;
                  accept;
                }
                RTS_DEVICE: {
                  krt_metric = 64;
                  accept;
                }
                RTS_BGP: {
                  krt_prefsrc = DN42_OWNIP; 
                  krt_metric = 256;
                  accept;
                }                
                else: reject;
              }
            };

            protocol kernel {
              scan time 20;
              metric 0;
              ipv6 {
                preference 100;
                import none;
                export filter to_kernel;
              };
            };

            filter to_kernel_v4 {
              case source {
                RTS_STATIC: {
                  krt_metric = 512;
                  accept;
                }
                RTS_DEVICE: {
                  krt_metric = 64;
                  accept;
                }
                RTS_BGP: {
                  krt_prefsrc = DN42_OWNIP_V4;
                  krt_metric = 256;
                  accept;
                }                
                else: reject;
              }
            };

            protocol kernel kernel4 {
              scan time 20;
              metric 0;
              ipv4 {
                preference 100;
                import none;
                export filter to_kernel_v4;
              };
            };

            protocol babel {
              interface "vxlan-mesh" {
                type wired;
                hello interval 2s;
                update interval 8s;
                rtt cost 192;
                rtt max 300ms;
                rtt decay 60;
                check link no;
                extended next hop yes;
                authentication mac;
                include "${config.vaultix.secrets.babel-auth.path}";
              };
              ipv6 {
                import where in_hortus();
                export filter to_hortus;
              };
            };
          '';
        };
        config = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
      };
      config = {
        systemd.services.bird.restartIfChanged = false;
        services.bird = {
          enable = true;
          config = config.bird.baseConfig + config.bird.config;
          checkConfig = false;
        };

        services.prometheus.exporters.bird = {
          enable = true;
          listenAddress = "[::]";
        };
      };
    };
}
