# A simple abstraction layer for almost all of my services' needs
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nginx;

  virtualHostOption = with lib; types.submodule {
    options = {
      subdomain = mkOption {
        type = types.str;
        example = "dev";
        description = ''
          Which subdomain, under config.networking.domain, to use
          for this virtual host.
        '';
      };

      port = mkOption {
        type = with types; nullOr port;
        default = null;
        example = 8080;
        description = ''
          Which port to proxy to, through 127.0.0.1, for this virtual host.
          This option is incompatible with `root`.
        '';
      };

      root = mkOption {
        type = with types; nullOr path;
        default = null;
        example = "/var/www/blog";
        description = ''
          The root folder for this virtual host.  This option is incompatible
          with `port`.
        '';
      };

      sso = {
        enable = mkEnableOption "SSO authentication";
      };

      extraConfig = mkOption {
        type = types.attrs; # FIXME: forward type of virtualHosts
        example = litteralExample ''
          {
            locations."/socket" = {
              proxyPass = "http://127.0.0.1:8096/";
              proxyWebsockets = true;
            };
          }
        '';
        default = { };
        description = ''
          Any extra configuration that should be applied to this virtual host.
        '';
      };
    };
  };
in
{
  imports = [
    ./sso
  ];

  options.my.services.nginx = with lib; {
    enable = mkEnableOption "Nginx";

    acme = {
      credentialsFile = mkOption {
        type = types.str;
        example = "/var/lib/acme/creds.env";
        description = ''
          Gandi API key file as an 'EnvironmentFile' (see `systemd.exec(5)`)
        '';
      };
    };

    monitoring = {
      enable = my.mkDisableOption "monitoring through grafana and prometheus";
    };

    virtualHosts = mkOption {
      type = types.listOf virtualHostOption;
      default = [ ];
      example = litteralExample ''
        [
          {
            subdomain = "gitea";
            port = 8080;
          }
          {
            subdomain = "dev";
            root = "/var/www/dev";
          }
          {
            subdomain = "jellyfin";
            port = 8096;
            extraConfig = {
              locations."/socket" = {
                proxyPass = "http://127.0.0.1:8096/";
                proxyWebsockets = true;
              };
            };
          }
        ]
      '';
      description = ''
        List of virtual hosts to set-up using default settings.
      '';
    };

    sso = {
      authKeyFile = mkOption {
        type = types.str;
        example = "/var/lib/nginx-sso/auth-key.txt";
        description = ''
          Path to the auth key.
        '';
      };

      subdomain = mkOption {
        type = types.str;
        default = "login";
        example = "auth";
        description = "Which subdomain, to use for SSO.";
      };

      port = mkOption {
        type = types.port;
        default = 8082;
        example = 8080;
        description = "Port to use for internal webui.";
      };

      users = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            passwordHashFile = mkOption {
              type = types.str;
              example = "/var/lib/nginx-sso/alice/password-hash.txt";
              description = "Path to file containing the user's password hash.";
            };
            totpSecretFile = mkOption {
              type = types.str;
              example = "/var/lib/nginx-sso/alice/totp-secret.txt";
              description = "Path to file containing the user's TOTP secret.";
            };
          };
        });
        example = litteralExample ''
          {
            alice = {
              passwordHashFile = "/var/lib/nginx-sso/alice/password-hash.txt";
              totpSecretFile = "/var/lib/nginx-sso/alice/totp-secret.txt";
            };
          }
        '';
        description = "Definition of users";
      };

      groups = mkOption {
        type = with types; attrsOf (listOf str);
        example = litteralExample ''
          {
            root = [ "alice" ];
            users = [ "alice" "bob" ];
          }
        '';
        description = "Groups of users";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ]
      ++ (lib.flip builtins.map cfg.virtualHosts ({ subdomain, ... } @ args:
      let
        conflicts = [ "port" "root" ];
        optionsNotNull = builtins.map (v: args.${v} != null) conflicts;
        optionsSet = lib.filter lib.id optionsNotNull;
      in
      {
        assertion = builtins.length optionsSet == 1;
        message = ''
          Subdomain '${subdomain}' must have exactly one of ${
            lib.concatStringsSep ", " (builtins.map (v: "'${v}'") conflicts)
          } configured.
        '';
      }))
      ++ (
      let
        ports = lib.my.mapFilter
          (v: v != null)
          ({ port, ... }: port)
          cfg.virtualHosts;
        portCounts = lib.my.countValues ports;
        nonUniquesCounts = lib.filterAttrs (_: v: v != 1) portCounts;
        nonUniques = builtins.attrNames nonUniquesCounts;
        mkAssertion = port: {
          assertion = false;
          message = "Port ${port} cannot appear in multiple virtual hosts.";
        };
      in
      map mkAssertion nonUniques
    ) ++ (
      let
        subs = map ({ subdomain, ... }: subdomain) cfg.virtualHosts;
        subsCounts = lib.my.countValues subs;
        nonUniquesCounts = lib.filterAttrs (_: v: v != 1) subsCounts;
        nonUniques = builtins.attrNames nonUniquesCounts;
        mkAssertion = v: {
          assertion = false;
          message = ''
            Subdomain '${v}' cannot appear in multiple virtual hosts.
          '';
        };
      in
      map mkAssertion nonUniques
    )
    ;

    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts =
        let
          domain = config.networking.domain;
          mkVHost = ({ subdomain, ... } @ args: lib.nameValuePair
            "${subdomain}.${domain}"
            (lib.my.recursiveMerge [
              # Base configuration
              {
                forceSSL = true;
                useACMEHost = domain;
              }
              # Proxy to port
              (lib.optionalAttrs (args.port != null) {
                locations."/".proxyPass =
                  "http://127.0.0.1:${toString args.port}";
              })
              # Serve filesystem content
              (lib.optionalAttrs (args.root != null) {
                inherit (args) root;
              })
              # VHost specific configuration
              args.extraConfig
              # SSO configuration
              (lib.optionalAttrs args.sso.enable {
                extraConfig = (args.extraConfig.extraConfig or "") + ''
                  error_page 401 = @error401;
                '';

                locations."@error401".return = ''
                  302 https://${cfg.sso.subdomain}.${config.networking.domain}/login?go=$scheme://$http_host$request_uri
                '';

                locations."/" = {
                  extraConfig =
                    (args.extraConfig.locations."/".extraConfig or "") + ''
                      # Use SSO
                      auth_request /sso-auth;

                      # Set username through header
                      auth_request_set $username $upstream_http_x_username;
                      proxy_set_header X-User $username;

                      # Renew SSO cookie on request
                      auth_request_set $cookie $upstream_http_set_cookie;
                      add_header Set-Cookie $cookie;
                    '';
                };

                locations."/sso-auth" = {
                  proxyPass = "http://localhost:${toString cfg.sso.port}/auth";
                  extraConfig = ''
                    # Do not allow requests from outside
                    internal;

                    # Do not forward the request body
                    proxy_pass_request_body off;
                    proxy_set_header Content-Length "";

                    # Set X-Application according to subdomain for matching
                    proxy_set_header X-Application "${subdomain}";

                    # Set origin URI for matching
                    proxy_set_header X-Origin-URI $request_uri;
                  '';
                };
              })
            ])
          );
        in
        lib.my.genAttrs' cfg.virtualHosts mkVHost;

      sso = {
        enable = true;

        configuration = {
          listen = {
            addr = "127.0.0.1";
            inherit (cfg.sso) port;
          };

          audit_log = {
            target = [
              "fd://stdout"
            ];
            events = [
              "access_denied"
              "login_success"
              "login_failure"
              "logout"
              "validate"
            ];
            headers = [
              "x-origin-uri"
              "x-application"
            ];
          };

          cookie = {
            domain = ".${config.networking.domain}";
            secure = true;
            authentication_key = {
              _secret = cfg.sso.authKeyFile;
            };
          };

          login = {
            title = "Ambroisie's SSO";
            default_method = "simple";
            hide_mfa_field = false;
            names = {
              simple = "Username / Password";
            };
          };

          providers = {
            simple =
              let
                applyUsers = lib.flip lib.mapAttrs cfg.sso.users;
              in
              {
                users = applyUsers (_: v: { _secret = v.passwordHashFile; });

                mfa = applyUsers (_: v: [{
                  provider = "totp";
                  attributes = {
                    secret = {
                      _secret = v.totpSecretFile;
                    };
                  };
                }]);

                inherit (cfg.sso) groups;
              };
          };

          acl = {
            rule_sets = [
              {
                rules = [{ field = "x-application"; present = true; }];
                allow = [ "@root" ];
              }
            ];
          };
        };
      };
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "login";
        inherit (cfg.sso) port;
      }
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Nginx needs to be able to read the certificates
    users.users.nginx.extraGroups = [ "acme" ];

    security.acme = {
      defaults.email = lib.my.mkMailAddress "bruno.acme" "belanyi.fr";

      acceptTerms = true;
      # Use DNS wildcard certificate
      certs =
        let
          domain = config.networking.domain;
        in
        with pkgs;
        {
          "${domain}" = {
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "gandiv5";
            inherit (cfg.acme) credentialsFile;
          };
        };
    };

    services.grafana.provision.dashboards = lib.mkIf cfg.monitoring.enable [
      {
        name = "NGINX";
        options.path = pkgs.nur.repos.alarsyo.grafanaDashboards.nginx;
        disableDeletion = true;
      }
    ];

    services.prometheus = lib.mkIf cfg.monitoring.enable {
      exporters.nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      scrapeConfigs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
  };
}
