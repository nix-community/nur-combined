{
  lib,
  config,
  ...
}:
let
  cfg = config.repack.bird;
in
{

  options = {
    repack.bird = {
      baseConfig = lib.mkOption {
        type = lib.types.lines;
        readOnly = true;
        default = ''
          log syslog all;
          # debug protocols all;
          timeformat protocol iso long;

          router id 10.0.0.${toString ((lib.getThisNodeFrom config).id + 1)};

          define HORTUS_OWNIP = ${lib.getIntraAddrFrom config};
          define HORTUS_PREFIX = fdcc::/16;
          define HORTUS_FIELD = [ fdcc::/16+ ];

          define DN42_ASN = 4242420291;
          define DN42_PREFIX = fdda:1965:1d5f::/48;
          define DN42_FIELD = [ fdda:1965:1d5f::/48+ ];

          protocol device {
            scan time 20;
          };

          protocol direct {
            ipv6;
            interface "anchor-*";
          };

          protocol static guard {
            ipv6;
            route HORTUS_PREFIX reject;
          }

          function in_hortus() -> bool {
            return net ~ HORTUS_FIELD;
          };

          filter to_hortus {
            if in_hortus() && (source = RTS_BABEL || source = RTS_DEVICE) then accept;
            reject;
          };

          filter to_kernel {
            case source {
              RTS_STATIC: {

                if proto = "guard" then reject;
                if proto = "vm" then accept;

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
        '';
      };
      config = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
    };
  };
  config = {
    services.bird = {
      enable = true;
      config = cfg.baseConfig + cfg.config;
    };
  };
}
