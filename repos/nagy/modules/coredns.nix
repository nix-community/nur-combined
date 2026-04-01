{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.coredns = {
    enable = true;
    package = pkgs.coredns.override {
      externalPlugins = [
        {
          name = "meship";
          repo = "github.com/zhoreeq/coredns-meship";
          version = "ba2685d1803672262638f752edb0ae97932b58fa";
        }
      ];
      vendorHash = "sha256-bnY7vHM3cZZaijOM7rGcWm14ANsnqIGFSvIOIY2bCaQ="; # for 26.05-unstable
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
    ''
    + lib.optionalString config.services.yggdrasil.enable ''
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
    '';
  };

  systemd.services.coredns.serviceConfig = {
    IPAddressDeny = "any";
    IPAddressAllow = [
      "localhost"
      "1.1.1.1"
      "1.0.0.1"
    ]
    ++ lib.optionals config.services.yggdrasil.enable [
      "324:71e:281a:9ed3::53"
    ];

    # Hardening
    MemoryDenyWriteExecute = true;
    ProtectHome = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectProc = "invisible";
    ProcSubset = "pid";
    PrivateTmp = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
    ];
  };

  networking.nameservers = [ "127.0.0.1" ];
}
