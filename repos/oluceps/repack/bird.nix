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

          protocol device {
            scan time 20;
          };

          protocol direct {
            ipv6;
            interface "anchor-*";
          };

          define HORTUS_FIELD = [ fdcc::/64+ ];
          define DN42_ASN = 4242420291;
          define DN42_FIELD = [ fdda:1965:1d5f::/48+ ];

          function in_hortus() {
            return net ~ HORTUS_FIELD;
          };

          filter to_hortus {
            if in_hortus() then {
              if source = RTS_BABEL || source = RTS_DEVICE then accept;
            }
            reject;
          };

          filter to_kernel {
            if source = RTS_BABEL then {
              krt_prefsrc = ${lib.getIntraAddrFrom config};
              krt_metric = 128;
              accept;
            }
            if source = RTS_DEVICE then {
              krt_metric = 64;
              accept;
            }
            reject;
          };

          protocol kernel {
            scan time 20;
            learn;
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
