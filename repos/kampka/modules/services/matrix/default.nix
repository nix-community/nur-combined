{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.kampka.services.matrix;

  riotOpts = { ... }: {
    options = {
      enable = mkEnableOption "riot web interface";

      hostName = mkOption {
        type = types.str;
        description = "The hostname of the riot web interface";
      };
    };
  };

  turnOpts = { ... }: {
    options = {
      enable = mkEnableOption "turn server";

      hostName = mkOption {
        type = types.str;
        description = "The hostname of the turn server";
      };

      turn_shared_secret = mkOption {
        type = types.str;
        description = "The turn shared secret file";
      };

      relay-ips = mkOption {
        type = types.listOf types.str;
        description = "A list of public IPs the turn server advertises on";
      };

      min-port = mkOption {
        type = types.int;
        default = 49152;
        description = "The lowest available UDP port of the turn port range";
      };

      max-port = mkOption {
        type = types.int;
        default = 44999;
        description = "The highest available UDP port of the turn port range";
      };

    };
  };

  matrixOpts = { ... }: {
    options = {

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/matrix-synapse";
        description = ''
          The directory used by the matrix server to store additional state,
          like user uploaded files etc.
        '';
      };

      serverName = mkOption {
        type = types.str;
        description = "The public server name of the matrix server";
      };

      hostName = mkOption {
        type = types.str;
        description = "The full hostname the matrix server is reached at";
      };

      registration_shared_secret = mkOption {
        type = types.str;
        description = "The registration shared secret";
      };

      federationPort = mkOption {
        type = types.int;
        default = 8448;
        description = "The federation port used by the home server";
      };

      clientPort = mkOption {
        type = types.int;
        default = 8008;
        description = "The client port used by the home server for clients to connect";
      };

      uploadSizeMB = mkOption {
        type = types.int;
        default = 100;
        description = "The maximum upload size for files in MB";
      };
    };
  };
in
{

  options.kampka.services.matrix = {
    enable = mkEnableOption "matrix home server";

    matrix = mkOption {
      type = types.submodule matrixOpts;
    };

    riot = mkOption {
      type = types.submodule riotOpts;
    };

    turn = mkOption {
      type = types.submodule turnOpts;
    };
  };

  config = mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      server_name = cfg.matrix.serverName;
      public_baseurl = "https://${cfg.matrix.hostName}/";
      dataDir = cfg.matrix.dataDir;
      tls_certificate_path = "/var/lib/acme/matrix-synapse/fullchain.pem";
      tls_private_key_path = "/var/lib/acme/matrix-synapse/key.pem";
      registration_shared_secret = cfg.matrix.registration_shared_secret;
      turn_shared_secret = cfg.turn.turn_shared_secret;
      listeners = [
        {
          # federation
          bind_address = "";
          port = cfg.matrix.federationPort;
          resources = [
            { compress = true; names = [ "client" "webclient" ]; }
            { compress = false; names = [ "federation" ]; }
          ];
          tls = true;
          type = "http";
          x_forwarded = false;
        }
        {
          # client
          bind_address = "127.0.0.1";
          port = cfg.matrix.clientPort;
          resources = [
            { compress = true; names = [ "client" "webclient" ]; }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
      ];
      max_upload_size = "${toString cfg.matrix.uploadSizeMB}M";
    };


    # web client proxy and setup certs
    services.nginx.virtualHosts."${cfg.matrix.hostName}" = lib.mkIf config.services.nginx.enable {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.matrix.clientPort}";
      };
    };

    # share certs with matrix-synapse and restart on renewal
    security.acme.certs."${cfg.matrix.hostName}" = {
      group = "nginx";
      postRun = ''
        mkdir -p "/var/lib/acme/matrix-synapse"
        cp -r "/var/lib/acme/${cfg.matrix.hostName}/"* "/var/lib/acme/matrix-synapse"
        chown -R acme:matrix-synapse "/var/lib/acme/matrix-synapse"
        systemctl reload nginx.service
        systemctl restart matrix-synapse.service
      '';
    };

    services.nginx.virtualHosts."${cfg.riot.hostName}" = lib.mkIf (config.services.nginx.enable && cfg.riot.enable) {
      forceSSL = true;
      enableACME = true;
      root =
        let
          config =
            let
              sample = builtins.fromJSON (builtins.readFile "${pkgs.element-web}/config.sample.json");
            in
            lib.recursiveUpdate sample {
              piwik = false;
              default_server_config."m.homeserver" = {
                base_url = "https://${cfg.matrix.hostName}";
                server_name = cfg.matrix.serverName;
              };
              disable_custom_urls = true;
              disable_guests = true;
            };
        in
        pkgs.element-web.override { conf = config; };
    };

    services.coturn = {
      enable = cfg.turn.enable;
      lt-cred-mech = true;
      use-auth-secret = true;
      static-auth-secret = cfg.turn.turn_shared_secret;
      realm = "${cfg.turn.hostName}";
      relay-ips = cfg.turn.relay-ips;
      no-tcp-relay = true;
      extraConfig = "
      cipher-list=\"HIGH\"
      no-loopback-peers
      no-multicast-peers
    ";
      secure-stun = true;
      cert = "/var/lib/acme/matrix-turnserver/fullchain.pem";
      pkey = "/var/lib/acme/matrix-turnserver/key.pem";
      min-port = cfg.turn.min-port;
      max-port = cfg.turn.max-port;
    };

    security.acme.certs."${cfg.turn.hostName}" = mkIf (cfg.turn.enable) {
      group = "nginx";
      postRun = ''
        mkdir -p "/var/lib/acme/matrix-turnserver"
        cp -r "/var/lib/acme/${cfg.turn.hostName}/"* "/var/lib/acme/matrix-turnserver"
        chown -R acme:turnserver "/var/lib/acme/matrix-turnserver"
        systemctl reload nginx.service 
        systemctl restart coturn.service
      '';
    };

    services.nginx.virtualHosts."${cfg.turn.hostName}" = mkIf (config.services.nginx.enable && cfg.turn.enable) {
      forceSSL = true;
      enableACME = true;
    };
    networking.firewall = {
      allowedTCPPorts = [
        cfg.matrix.federationPort
        5349 # STUN tls
        5350 # STUN tls alt
      ];
      allowedUDPPortRanges = [
        { from = cfg.turn.min-port; to = cfg.turn.max-port; } # TURN relay
      ];
    };
  };
}
