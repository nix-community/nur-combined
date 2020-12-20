{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.electrumx;
    conf = pkgs.writeScript "electrumx.conf" ''
      COIN = ${cfg.coin}
      NET = ${cfg.net}
      DB_DIRECTORY = ${cfg.dbDirectory}
      DAEMON_URL = ${builtins.concatStringsSep "," cfg.daemonUrl}
      SERVICES = ${builtins.concatStringsSep "," cfg.services}
      ${optionalString (cfg.reportServices != []) "REPORT_SERVICES = ${builtins.concatStringsSep "," cfg.reportServices}"}
      SSL_CERTFILE = ${cfg.ssl.certfile}
      SSL_KEYFILE = ${cfg.ssl.keyfile}
      ${optionalString (cfg.eventLoopPolicy != "asyncio") "EVENT_LOOP_POLICY = ${cfg.eventLoopPolicy}"}
      PEER_DISCOVERY = ${cfg.peer.discovery}
      ${optionalString (! cfg.peer.announce) "PEER_ANNOUNCE ="}
      ${optionalString (cfg.peer.blacklistUrl != "") "BLACKLIST_URL = ${cfg.peer.blacklistUrl}"}
      ${optionalString cfg.peer.tor.enable torProxyConf}
    '';

    torProxyConf = ''
      ${optionalString cfg.peer.tor.forceProxy "FORCE_PROXY = true"}
      TOR_PROXY_HOST = ${toString cfg.peer.tor.host}
      TOR_PROXY_PORT = ${toString cfg.peer.tor.port}
    '';
in {
  options = {

    services.electrumx = {
      user = mkOption {
        type = types.str;
        default = "electrumx";
        description = "The user as which to run electrumx.";
      };

      group = mkOption {
        type = types.str;
        default = cfg.user;
        description = "The group as which to run electrumx.";
      };

      enable = mkEnableOption "Enable electrumx, an electrum-server implementation.";

      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.emmanuelrosa.electrumx;
        defaultText = "pkgs.electrumx";
        description = "The package providing electrumx.";
      };

      coin = mkOption {
        type = types.str;
        default = "Bitcoin";
        example = "Bitcoin";
        description = "Must be a NAME from one of the Coin classes in https://github.com/spesmilo/electrumx/blob/master/electrumx/lib/coins.py For example, Bitcoin.";
      };

      net = mkOption {
        type = types.str;
        default = "mainnet";
        example = "mainnet";
        description = "Must be a NET from one of the Coin classes in https://github.com/spesmilo/electrumx/blob/master/electrumx/lib/coins.py. Defaults to mainnet.";
      };

      dbDirectory = mkOption {
        type = types.str;
        default = "/var/lib/electrumx";
        example = "/var/lib/electrumx";
        description = "The path to the database directory.";
      };

      daemonUrl = mkOption {
        type = types.listOf types.str;
        default = [];
        example = "[ 'username:password@localhost:8332' 'https://username:password@somebtcnode.com:8332' ]";
        description = ''
          A list of daemon URLs (ex. Bitcoin Core RPC). If more than one is provided ElectrumX will initially connect to the first, and failover to subsequent ones round-robin style if one stops working.

          The leading http:// is optional, as is the trailing slash. The :port part is also optional and will default to the standard RPC port for COIN and NET if omitted.
          '';
      };

      services = mkOption {
        type = types.listOf types.str;
        default = [ "rpc://" ];
        example = "[ 'rpc://127.0.0.1:50002 'tcp://myelectrumx.net:50002' ]";
        description = ''
        A list of services ElectrumX will accept incoming connections for.

         This determines what interfaces and ports the server listens on, so must be set correctly for any connection to the server to succeed. If unset or empty, ElectrumX will not listen for any incoming connections.
          '';
      };

      reportServices = mkOption {
        type = types.listOf types.str;
        default = [];
        example = "[ 'tcp://sv.usebsv.com:50001 'ssl://sv.usebsv.com:50002' ]";
        description = ''
        A list of services ElectrumX will advertize and other servers in the server network (if peer discovery is enabled), and any successful connection.

        This must be set correctly, taking account of your network, firewall and router setup, for clients and other servers to see how to connect to your server. If not set or empty, no services are advertized.
          '';
      };

      eventLoopPolicy = mkOption {
        type = types.enum [ "asyncio" "uvloop" ];
        default = "asyncio";
        description = "The name of an event loop policy to replace the default asyncio policy.";
      };

      ssl = {
        certfile = mkOption {
          type = types.path;
          example = "/etc/electrumx/server.crt";
          description = "The filesystem path to your SSL certificate file.";
        };

        keyfile = mkOption {
          type = types.path;
          example = "/etc/electrumx/server.key";
          description = "The filesystem path to your SSL keu file.";
        };
      };

      peer = {
        discovery = mkOption {
          type = types.enum [ "on" "off" "self" ];
          default = "on";
          example = "self";
          description = ''
          If on, ElectrumX will occasionally connect to and verify its network of peer servers.

          If off, peer discovery is disabled and a hard-coded default list of servers will be read in and served. If set to self then peer discovery is disabled and the server will only return itself in the peers list.
          '';
        };

        announce = mkOption {
          type = types.bool;
          default = true;
          description = ''
            When true, ElectrumX will announce itself to peers.

            If peer discovery is off this environment variable has no effect, because ElectrumX only announces itself to peers when doing peer discovery if it notices it is not present in the peer’s returned list.
          '';
        };

        blacklistUrl = mkOption {
          type = types.str;
          default = "";
          description = ''
            URL to retrieve a list of blacklisted peers. If not set, a coin-specific default is used.
          '';
        };

        tor = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Allow/disallow electrumx to use a Tor proxy.";
          };

          forceProxy = mkOption {
            type = types.bool;
            default = false;
            description = ''
              By default peer discovery happens over the clear internet. Enable this to force peer discovery to be done via the proxy. This might be useful if you are running a Tor service exclusively and wish to keep your IP address private.
            '';
          };

          host = mkOption {
            type = types.str;
            default = "localhost";
            description = "The host where your Tor proxy is running.";
          };

          port = mkOption {
            type = types.port;
            default = 9050;
            example = 9051;
            description = "The port on which the Tor proxy is running.";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.electrumx = {
      description = "Electrum server daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = "${conf}";
        ExecStart = "${cfg.package}/bin/electrumx_server";
        User = cfg.user;
        Group = cfg.group;
        LimitNOFILE = 8192;
        TimeoutStopSec = "30min";
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dbDirectory}' 0770 '${cfg.user}' '${cfg.group}' - -"
    ];

    users.users."${cfg.user}" = {
      group = cfg.group;
      description = "ElectrumX daemon user";
      home = cfg.dbDirectory;
      isSystemUser = true;
    };

    users.groups."${cfg.group}" = { };
  };

  meta.maintainers = with maintainers; [ emmanuelrosa ];
}
