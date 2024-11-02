{ lib, config, ... }:
let cfg = config.eownerdead;
in with lib; {
  options.eownerdead = {
    tor = mkEnableOption (mdDoc ''
      Enable Tor client.
    '');
    dnsOverTor = mkEnableOption (mdDoc ''
      Pass DNS requests to Tor.
    '');
  };

  config = mkIf cfg.tor {
    eownerdead.encryptedDns = !cfg.tor;

    services = {
      tor = {
        enable = true;
        client = {
          enable = true;
          dns.enable = true;
          # https://gitlab.torproject.org/legacy/trac/-/wikis/TorBrowserBundleSAQ#using-a-local-tor-socks-daemon
          socksListenAddress = {
            addr = "127.0.0.1";
            port = 9050;
            IsolateDestAddr = true;
            IPv6Traffic = true;
            PreferIPv6 = true;
          };
        };
        controlSocket.enable = true;
        settings = {
          ControlPort = [{ addr = "127.0.0.1"; port = 9051; }];
          CookieAuthentication = true;
          CookieAuthFile = "/run/tor/control.authcookie";
          CookieAuthFileGroupReadable = true;
        };
        settings.DNSPort = mkIf config.eownerdead.dnsOverTor [{
          addr = "127.0.0.1";
          port = 53;
        }];
      };

      resolved = mkIf cfg.tor (mkDefault {
        enable = true; # For caching DNS requests.
        fallbackDns = [ "" ]; # Disable compiled-in fallback DNS.
      });
    };

    networking.nameservers = mkIf cfg.tor (mkDefault [ "127.0.0.1" ]);

    systemd.services.tor.serviceConfig.RuntimeDirectoryMode = "0730";

    environment.sessionVariables = let torCfg = config.services.tor.settings;
    in {
      TOR_CONTROL_COOKIE_AUTH_FILE = torCfg.CookieAuthFile;
      TOR_CONTROL_PORT = (builtins.head torCfg.ControlPort).port;
      TOR_SOCKS_PORT = (builtins.head torCfg.SOCKSPort).port;
      TOR_SKIP_LAUNCH = true;
    };
  };
}
