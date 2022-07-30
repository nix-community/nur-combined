{ config, lib, pkgs, options, ... }:

with lib;
let
  cfg = config.programs.cjdns;
  server = cfg.enable && cfg.server;
  client = cfg.enable && !cfg.server;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  lists = pkgs.nur.repos.dukzcry.lib.lists;
in {
  options.programs.cjdns = {
    enable = mkEnableOption ''
      preconfigured Cjdns
    '';
    server = mkEnableOption ''
      server mode
    '';
    logging = mkEnableOption ''
      logging
    '';
    interface = mkOption {
      type = types.str;
      default = "cjdns0";
    };
    address = mkOption {
      type = ip4.type;
      example = ''
        ip4.fromString "10.0.2.1/24"
      '';
    };
    keys = mkOption {
      type = types.listOf types.str;
    };
    postStart = mkOption {
      type = types.str;
      default = "";
      example = ''
        ip route add dev ${config.programs.cjdns.interface} 10.0.0.0/24
        echo -e "nameserver 10.0.0.2\nsearch local" | resolvconf -a ${config.programs.cjdns.interface}
      '';
    };
    preStop = mkOption {
      type = types.str;
      default = "";
      example = ''
        resolvconf -d ${config.programs.cjdns.interface}
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.cjdns.enable = true;
      services.cjdns.UDPInterface = {
        bind = "0.0.0.0:53143";
        connectTo = {
          "142.93.148.79:32307" = {
            login = "public-peer";
            password = "242yl4g4nmu0rygusyhxu9xd13lrhuj";
            peerName = "kusoneko.moe";
            publicKey = "nvl82112jgj26sgv6r7sbuqc7wh1n7w1stsj327lbcu8n2yycf20.k";
          };
          "45.32.152.232:5078" = {
            login = "default-login";
            password = "v277jzr7r3jgk0vk1389b2c3h0gy98t";
            peerName = "sssemil.k";
            publicKey = "08bz912l989nzqc21q9x5qr96ns465nd71f290hb9q40z94jjw60.k";
          };
          "80.218.59.16:56879" = {
            login = "theswissbay-peering-login";
            password = "rr1lsx8vvxq7m5107gvsn98gc2h2l54";
            peerName = "theswissbay.ch";
            publicKey = "nuvtkly8swgkwsyyjrv89f4y4y0w3x17w61twgsfh9zv1r87h060.k";
          };
        };
      };
      services.cjdns.extraConfig = {
        logging = optionalAttrs cfg.logging {
          logTo = "stdout";
        };
        router = {
          interface = {
            tunDevice = cfg.interface;
          };
          ipTunnel = {
            allowedConnections = optionals server (lists.foldmap
              { _addr = ip4.next cfg.address; }
              []
              (key: acc: let
                 prev = last acc;
              in rec {
                _addr = ip4.next prev._addr;
                publicKey = key;
                ip4Address = prev._addr.address;
                ip4Prefix = cfg.address.prefixLength;
              })
              cfg.keys
            );
            outgoingConnections = optionals client cfg.keys;
          };
        };
      };
    })
    (mkIf server {
      systemd.services.cjdns.path = with pkgs; [ iproute2 ];
      systemd.services.cjdns.postStart = ''
        set +e
        ip addr add dev ${cfg.interface} ${ip4.toCIDR cfg.address}
        ${cfg.postStart}
        true
      '';
      systemd.services.cjdns.preStop = ''
        set +e
        ip addr del dev ${cfg.interface} ${ip4.toCIDR cfg.address}
        ${cfg.preStop}
        true
      '';
    })
    (mkIf client {
      systemd.services.cjdns.path = with pkgs; [ iproute2 openresolv ];
      systemd.services.cjdns.postStart = ''
        set +e
        ${cfg.postStart}
        true
      '';
      systemd.services.cjdns.preStop = ''
        set +e
        ${cfg.preStop}
        true
      '';
      systemd.services.cjdns.wantedBy = mkForce [ ];
    })
  ];
}
