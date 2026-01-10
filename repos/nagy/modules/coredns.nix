{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.coredns;
in
{
  services.coredns = {
    package = pkgs.coredns.override {
      # ...
    };
    config = ''
      . {
        forward . tls://1.1.1.1 tls://1.0.0.1 {
            tls_servername cloudflare-dns.com
        }
        cache {
          success 5000 3600 3600
          disable denial
        }
        log
      }

      ygg. {
        hosts /etc/hosts {
          fallthrough
        }
        forward . [324:71e:281a:9ed3::53]:53
        cache {
          success 5000 3600 3600
          denial 2500 1800 1800
        }
        log
      }
      # do not resolve onion domains
      onion. {
        template ANY ANY {
            rcode NXDOMAIN
        }
      }

      # do not resolve i2p domains
      i2p. {
        template ANY ANY {
            rcode NXDOMAIN
        }
      }
    '';
  };

  networking.nameservers = lib.mkIf cfg.enable [ "127.0.0.1" ];
}
