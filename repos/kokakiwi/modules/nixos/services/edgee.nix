{ config, pkgs, lib, ... }:
let
  cfg = config.services.edgee;

  toml = pkgs.formats.toml { };

  configFile = toml.generate "edgee.toml" cfg.config;
in {
  options.services.edgee = with lib; {
    enable = mkEnableOption "Edgee Proxy";
    package = mkOption {
      type = types.package;
    };

    runAsRoot = mkOption {
      type = types.bool;
      default = lib.hasSuffix ":80" cfg.http.listenAddress;
    };

    http = {
      listenAddress = mkOption {
        type = types.str;
        default = "0.0.0.0:8080";
      };
      forceHttps = mkOption {
        type = types.bool;
        default = cfg.https.listenAddress != null;
      };
    };
    https = {
      listenAddress = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      certFile = mkOption {
        type = types.path;
      };
      keyFile = mkOption {
        type = types.path;
      };
    };

    components = {
      dataCollection = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            path = mkOption {
              type = types.path;
            };
            settings = mkOption {
              type = types.attrs;
              default = { };
            };
          };
        });
        default = { };
      };
    };

    routing = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          backends = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                default = mkOption {
                  type = types.bool;
                  default = false;
                };
                address = mkOption {
                  type = types.str;
                };
                enableSsl = mkOption {
                  type = types.bool;
                  default = false;
                };
              };
            });
            default = { };
          };
        };
      });
      default = { };
    };

    config = mkOption {
      type = types.submodule {
        freeformType = toml.type;
        options = {
          log = {
            level = mkOption {
              type = types.enum [ "trace" "debug" "info" ];
              default = "info";
            };
          };

          http = {
            address = mkOption {
              type = types.str;
              default = cfg.http.listenAddress;
            };
            force_https = mkOption {
              type = types.bool;
              default = cfg.http.forceHttps;
            };
          };

          compute = {
            proxy_only = mkOption {
              type = types.bool;
              default = false;
            };
            enforce_no_store_policy = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.edgee = {
      config = {
        https = lib.mkIf (cfg.https.listenAddress != null) {
          address = lib.mkDefault cfg.https.listenAddress;
          cert = lib.mkDefault cfg.https.certFile;
          key = lib.mkDefault cfg.https.keyFile;
        };

        components = {
          data_collection = lib.mapAttrsToList (id: component: {
            inherit id;
            file = component.path;
            inherit (component) settings;
          }) cfg.components.dataCollection;
        };

        routing = lib.mapAttrsToList (domain: route: {
          inherit domain;

          backends = lib.mapAttrsToList (name: backend: {
            inherit name;
            inherit (backend) default address;
            enable_ssl = backend.enableSsl;
          }) route.backends;
        }) cfg.routing;
      };
    };

    environment.etc."edgee.toml".source = configFile;

    systemd.services.edgee = {
      description = "The full-stack edge platform for your edge oriented applications";

      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve --config ${configFile}";

        DynamicUser = lib.mkIf (!cfg.runAsRoot) true;
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };
  };
}
