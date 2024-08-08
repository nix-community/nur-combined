{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vpn;
  tor =  cfg.enable && cfg.tor.enable;
in {
  options.services.vpn = {
    enable = mkEnableOption "";
    address = mkOption {
      type = types.str;
    };
    address6 = mkOption {
      type = types.str;
      default = "";
    };
    resolver = mkOption {
      type = types.submodule {
        options = {
          addresses = mkOption {
            type = types.listOf types.str;
          };
          ipv6 = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };
    };
    tor = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
      default = {};
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.nginx.enable = true;
      services.nginx.proxyResolveWhileRunning = true;
      services.nginx.streamConfig = ''
        server {
          resolver ${toString cfg.resolver.addresses} ${optionalString (!cfg.resolver.ipv6) "ipv6=off"};
          listen ${cfg.address}:443;
          ${optionalString (cfg.address6 != "") "listen [${cfg.address6}]:443;"}
          ssl_preread on;
          proxy_pass $ssl_preread_server_name:443;
          proxy_bind ${cfg.address};
        }
      '';
    })
    (mkIf tor {
      services.tor.enable = true;
      services.tor.settings = {
        ExcludeExitNodes = "{RU}";
        TransPort = [{ addr = cfg.address; port = 9040; }];
      };
      networking.nftables.tables = {
        vpn = {
          family = "ip";
          content = ''
            chain out {
              type nat hook output priority mangle;
              ip protocol tcp ip saddr ${cfg.address} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
            }
          '';
        };
      };
    })
  ];
}
