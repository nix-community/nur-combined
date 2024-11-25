{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.blacklist;
  tor =  cfg.enable && cfg.tor.enable;
in {
  options.services.blacklist = {
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
      services.nginx.resolver = {
        addresses = cfg.resolver.addresses;
        ipv6 = cfg.resolver.ipv6;
      };
      services.nginx.virtualHosts = {
        vpn = {
          default = true;
          listen = [
            { addr = cfg.address; port = 80; }
          ] ++ optional (cfg.address6 != "") { addr = "[${cfg.address6}]"; port = 80; };
          locations."/" = {
            proxyPass = "http://$http_host:80";
            extraConfig = ''
              proxy_bind ${cfg.address};
            '';
          };
        };
      };
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
        UseBridges = true;
        ClientTransportPlugin = "snowflake exec ${pkgs.snowflake}/bin/client";
        Bridge = [
          "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://snowflake-broker.torproject.net.global.prod.fastly.net/ fronts=foursquare.com,github.githubassets.com ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
        ];
      };
      networking.nftables.tables = {
        blacklist = {
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
