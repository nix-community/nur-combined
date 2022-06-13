# Matrix homeserver setup, using different endpoints for federation and client
# traffic. The main trick for this is defining two nginx servers endpoints for
# matrix.domain.com, each listening on different ports.
#
# Configuration inspired by :
#
# - https://github.com/delroth/infra.delroth.net/blob/master/roles/matrix-synapse.nix
# - https://nixos.org/manual/nixos/stable/index.html#module-services-matrix
#
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    optionals
    ;

  cfg = config.my.services.matrix;
  my = config.my;

  federationPort = {
    public = 8448;
    private = 11338;
  };
  clientPort = {
    public = 443;
    private = 11339;
  };

  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.matrix = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Matrix Synapse";

    secretConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/var/run/my_secrets/config.secret";
      description = "Secrets file included in configuration";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      ensureDatabases = ["matrix-synapse"];
      ensureUsers = [
        {
          name = "matrix-synapse";
          ensurePermissions."DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
        }
      ];
    };

    services.postgresqlBackup = {
      databases = ["matrix-synapse"];
    };

    services.matrix-synapse = {
      enable = true;

      extraConfigFiles = optionals (cfg.secretConfigFile != null) [
        cfg.secretConfigFile
      ];

      settings = let
        logConfig = ''
          version: 1

          # In systemd's journal, loglevel is implicitly stored, so let's omit it
          # from the message text.
          formatters:
              journal_fmt:
                  format: '%(name)s: [%(request)s] %(message)s'

          filters:
              context:
                  (): synapse.util.logcontext.LoggingContextFilter
                  request: ""

          handlers:
              journal:
                  class: systemd.journal.JournalHandler
                  formatter: journal_fmt
                  filters: [context]
                  SYSLOG_IDENTIFIER: synapse

          root:
              level: WARN
              handlers: [journal]

          disable_existing_loggers: False
        '';
      in {
        server_name = domain;
        public_baseurl = "https://matrix.${domain}";

        account_threepid_delegates = {
          msisdn = "https://vector.im";
        };

        listeners = [
          # Federation
          {
            bind_addresses = ["::1"];
            port = federationPort.private;
            tls = false; # Terminated by nginx.
            x_forwarded = true;
            resources = [
              {
                names = ["federation"];
                compress = false;
              }
            ];
          }

          # Client
          {
            bind_addresses = ["::1"];
            port = clientPort.private;
            tls = false; # Terminated by nginx.
            x_forwarded = true;
            resources = [
              {
                names = ["client"];
                compress = false;
              }
            ];
          }
        ];

        experimental_features = {
          spaces_enabled = true;
        };

        use_presence = true;

        email = {
          require_transport_security = true;
        };

        log_config = pkgs.writeText "log_config.yaml" logConfig;
      };
    };

    services.nginx = {
      virtualHosts = {
        "matrix.${domain}" = {
          onlySSL = true;
          useACMEHost = fqdn;

          locations = let
            proxyToClientPort = {
              proxyPass = "http://[::1]:${toString clientPort.private}";
            };
          in {
            # Or do a redirect instead of the 404, or whatever is appropriate
            # for you. But do not put a Matrix Web client here! See the
            # Element web section below.
            "/".return = "404";

            "/_matrix" = proxyToClientPort;
            "/_synapse/client" = proxyToClientPort;
          };

          listen = [
            {
              addr = "0.0.0.0";
              port = clientPort.public;
              ssl = true;
            }
            {
              addr = "[::]";
              port = clientPort.public;
              ssl = true;
            }
          ];
        };

        # same as above, but listening on the federation port
        "matrix.${domain}_federation" = rec {
          onlySSL = true;
          serverName = "matrix.${domain}";
          useACMEHost = fqdn;

          locations."/".return = "404";

          locations."/_matrix" = {
            proxyPass = "http://[::1]:${toString federationPort.private}";
          };

          listen = [
            {
              addr = "0.0.0.0";
              port = federationPort.public;
              ssl = true;
            }
            {
              addr = "[::]";
              port = federationPort.public;
              ssl = true;
            }
          ];
        };

        "${domain}" = {
          forceSSL = true;
          useACMEHost = fqdn;

          locations."= /.well-known/matrix/server".extraConfig = let
            server = {"m.server" = "matrix.${domain}:${toString federationPort.public}";};
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';

          locations."= /.well-known/matrix/client".extraConfig = let
            client = {
              "m.homeserver" = {"base_url" = "https://matrix.${domain}";};
              "m.identity_server" = {"base_url" = "https://vector.im";};
            };
            # ACAO required to allow element-web on any URL to request this json file
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        };

        # Element Web app deployment
        #
        "chat.${domain}" = {
          useACMEHost = fqdn;
          forceSSL = true;

          root = pkgs.element-web.override {
            conf = {
              default_server_config = {
                "m.homeserver" = {
                  "base_url" = "https://matrix.${domain}";
                  "server_name" = "${domain}";
                };
                "m.identity_server" = {
                  "base_url" = "https://vector.im";
                };
              };
              showLabsSettings = true;
              defaultCountryCode = "FR"; # cocorico
              roomDirectory = {
                "servers" = [
                  "matrix.org"
                  "mozilla.org"
                  "prologin.org"
                ];
              };
            };
          };
        };
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = ["chat.${domain}" "matrix.${domain}" domain];

    # For administration tools.
    environment.systemPackages = [pkgs.matrix-synapse];

    networking.firewall.allowedTCPPorts = [
      clientPort.public
      federationPort.public
    ];

    my.services.restic-backup = let
      dataDir = config.services.matrix-synapse.dataDir;
    in {
      paths = [dataDir];
      # this is just caching for other servers media, doesn't need backup
      exclude = ["${dataDir}/media/remote_*"];
    };
  };
}
