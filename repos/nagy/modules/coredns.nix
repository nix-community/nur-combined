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
      externalPlugins = [
        {
          name = "meship";
          repo = "github.com/zhoreeq/coredns-meship";
          version = "ba2685d1803672262638f752edb0ae97932b58fa";
        }
      ];
      vendorHash = "sha256-XNmlaBdxqQyJyNwa1juijHytB3SzZjtds3eDTEYAF7c="; # for 25.05
    };
    config = ''
      . {
        bind 127.0.0.1
        forward . tls://1.1.1.1 tls://1.0.0.1 {
            tls_servername cloudflare-dns.com
        }
        cache {
          success 5000 3600 3600
          disable denial
        }
        log
      }

      # Alfis
      # https://github.com/Revertron/Alfis
      anon. btn. conf. index. merch. mirror. mob. screen. srv. ygg. {
        bind 127.0.0.1
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

      meship. {
        bind 127.0.0.1
        meship
        log
      }

      # do not resolve onion domains
      onion. {
        bind 127.0.0.1
        template ANY ANY {
            rcode NXDOMAIN
        }
      }

      # do not resolve i2p domains
      i2p. {
        bind 127.0.0.1
        template ANY ANY {
            rcode NXDOMAIN
        }
      }
    '';
  };

  networking.nameservers = lib.mkIf cfg.enable [ "127.0.0.1" ];
}
