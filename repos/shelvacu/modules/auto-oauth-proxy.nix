{
  lib,
  config,
  pkgs,
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  # kanidmDomain = config.services.kanidm.serverSettings.domain;
  # kanidmUrl = "https://${kanidmDomain}";
  outerConfig = config;
  instanceModule =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        appDomain = mkOption { type = types.str; };
        kanidmDomain = mkOption {
          type = types.str;
          default = outerConfig.vacu.oauthProxy.kanidmDomain;
          defaultText = ''`config.vacu.oauthProxy.kanidmDomain`'';
        };
        caddyConfig = mkOption { type = types.lines; };
        requireOauth = mkOption {
          type = types.bool;
          default = true;
        };
        displayName = mkOption {
          type = types.str;
          default = config.name;
          defaultText = "name";
        };
        kanidmMembers = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        configureCaddy = mkOption {
          type = types.bool;
          default = true;
        };
        configureKanidm = mkOption {
          type = types.bool;
          default = true;
        };
        clientSecret = mkOption {
          default = {
            generate = true;
          };
          type = types.attrTag {
            generate = mkOption { type = types.bool; };
            path = mkOption { type = types.path; };
            sops = mkOption {
              type = types.submodule (
                { ... }:
                {
                  options.sopsFile = mkOption { type = types.path; };
                  options.key = mkOption { type = types.str; };
                }
              );
            };
          };
        };
        basicAuthAccounts = mkOption {
          type = types.attrsOf (
            types.coercedTo vaculib.types.caddyStr lib.singleton (types.listOf vaculib.types.caddyStr)
          );
          default = { };
        };
        settings = mkOption {
          type = types.attrsOf types.anything;
          default = { };
        };
        out = {
          basicAuthEnabled = mkOption {
            type = types.bool;
            readOnly = true;
          };
          fullName = mkOption {
            type = types.str;
            readOnly = true;
          };
          socketDir = mkOption {
            type = types.path;
            readOnly = true;
          };
          socketPath = mkOption {
            type = types.path;
            readOnly = true;
          };
          generateClientSecret = mkOption {
            type = types.bool;
            readOnly = true;
          };
          clientSecretDir = mkOption {
            type = types.path;
            readOnly = true;
          };
          clientSecretFile = mkOption {
            type = types.path;
            readOnly = true;
          };
          tomlFile = mkOption {
            type = types.path;
            readOnly = true;
          };
          kanidmGroup = mkOption {
            type = types.str;
            readOnly = true;
          };
          kanidmUrl = mkOption {
            type = types.str;
            readOnly = true;
          };
        };

        assertions = mkOption {
          internal = true;
          type = types.listOf (
            types.submodule (
              { ... }:
              {
                options.assertion = mkOption { type = types.bool; };
                options.message = mkOption { type = types.str; };
              }
            )
          );
          default = [ ];
        };
      };
      config.assertions = [
        {
          assertion = config.out.generateClientSecret -> (config.configureCaddy && config.configureKanidm);
          message = ''(clientSecret == "generate") -> (configureCaddy && configureKanidm)'';
        }
        {
          assertion = config.configureCaddy || config.configureKanidm;
          message = "configureCaddy || configureKanidm";
        }
        {
          assertion = config.name == (lib.toLower config.name);
          message = "names must be lowercase";
        }
      ];
      config.settings = {
        provider = "oidc";
        scope = "openid email";
        oidc_issuer_url = "${config.out.kanidmUrl}/oauth2/openid/${config.name}";
        client_id = config.name;
        redirect_url = "https://${config.appDomain}/oauth2/callback";
        # oidc_groups_claim = "${config.name}_group";
        # allowed_groups = [];
        client_secret_file = config.out.clientSecretFile;
        email_domains = [ "*" ];
        http_address = "unix://${config.out.socketPath}";
        set_xauthrequest = true;
        reverse_proxy = true;
      };
      config.out = {
        basicAuthEnabled = config.configureCaddy && (config.basicAuthAccounts != { });
        fullName = "${config.name}-oauth2-proxy";
        socketDir = "/run/${config.out.fullName}-socket";
        socketPath = "${config.out.socketDir}/socket.unix";
        generateClientSecret = config.clientSecret ? generate;
        clientSecretFile =
          if config.out.generateClientSecret then
            "/var/cache/${config.out.fullName}-client-secret/secret"
          else if config.clientSecret ? sops then
            outerConfig.sops.secrets.${config.out.fullName}.path
          else
            config.clientSecret.path;
        clientSecretDir = builtins.dirOf config.out.clientSecretFile;
        tomlFile = pkgs.writers.writeTOML "${config.name}-config.toml" config.settings;
        kanidmGroup = "${config.name}_access";
        kanidmUrl = "https://${config.kanidmDomain}";
      };
    };

  mergeWhereEach =
    cond: f:
    lib.pipe config.vacu.oauthProxy.instances [
      (builtins.attrValues)
      (builtins.filter (cfg: cfg.enable && cond cfg))
      (map f)
      lib.mkMerge
    ];

  mergeEach = mergeWhereEach (_: true);
in
{
  options.vacu.oauthProxy = {
    instances = mkOption { type = types.attrsOf (types.submodule instanceModule); };
    kanidmDomain = mkOption {
      type = types.str;
      default = "id.shelvacu.com";
    };
  };

  config = {
    assertions = mergeEach (
      cfg:
      map (ass: {
        inherit (ass) assertion;
        message = "In vacu.oauthProxy.instances.${cfg.name}: ${ass.message}";
      }) cfg.assertions
    );

    sops.secrets = mergeWhereEach (cfg: cfg.clientSecret ? sops) (cfg: {
      ${cfg.out.fullName} = {
        inherit (cfg.clientSecret.sops) key sopsFile;
        group = "${cfg.out.fullName}-client-secret";
        mode = vaculib.accessModeStr {
          user = "all";
          group = {
            read = true;
            write = false;
            execute = true;
          };
        };
        restartUnits =
          [ ]
          ++ lib.optional (cfg.configureKanidm) "kanidm.service"
          ++ lib.optional (cfg.configureCaddy) "${cfg.out.fullName}.service";
      };
    });

    users.users = mergeWhereEach (cfg: cfg.configureCaddy) (cfg: {
      ${cfg.out.fullName} = {
        isSystemUser = true;
        group = cfg.out.fullName;
      };
    });

    users.groups = lib.mkMerge [
      (mergeEach (cfg: {
        "${cfg.out.fullName}-client-secret".members =
          [ ]
          ++ lib.optional cfg.configureKanidm "kanidm"
          ++ lib.optional cfg.configureCaddy cfg.out.fullName;
      }))
      (mergeWhereEach (cfg: cfg.configureCaddy) (cfg: {
        ${cfg.out.fullName} = { };
        "${cfg.out.fullName}-socket".members = [
          "caddy"
          cfg.out.fullName
        ];
      }))
    ];

    systemd.tmpfiles.settings.oauth-proxy-instances = mergeWhereEach (cfg: cfg.configureCaddy) (cfg: {
      ${cfg.out.socketDir}.d = {
        user = cfg.out.fullName;
        group = "${cfg.out.fullName}-socket";
        mode = vaculib.accessModeStr {
          user = "all";
          group = "all";
        };
      };
    });

    systemd.tmpfiles.settings.oauth-proxy-secrets =
      mergeWhereEach (cfg: cfg.out.generateClientSecret)
        (cfg: {
          ${cfg.out.clientSecretDir}.d = {
            user = "root";
            group = "${cfg.out.fullName}-client-secret";
            mode = vaculib.accessModeStr {
              user = "all";
              group = {
                read = true;
                write = false;
                execute = true;
              };
            };
          };
        });

    systemd.services = mergeEach (cfg: {
      ${if cfg.configureCaddy then cfg.out.fullName else null} = {
        description = "oauth2-proxy instance ${cfg.name}";
        wantedBy = [ "caddy.service" ];
        after = [ "kanidm.service" ];
        confinement.enable = true;
        confinement.packages = [
          cfg.out.tomlFile
          pkgs.coreutils
          pkgs.oauth2-proxy
        ];
        preStart = ''
          declare cookie_secret_fn="$STATE_DIRECTORY/cookie-secret"
          declare file_size=0
          if [[ -f "$cookie_secret_fn" ]]; then
            file_size="$(stat -c%s -- "$cookie_secret_fn")"
          else
            touch -- "$cookie_secret_fn"
          fi
          chmod u=rw,g=,o= "$cookie_secret_fn"
          if [[ $file_size != 32 ]]; then
            dd if=/dev/urandom bs=32 count=1 > "$cookie_secret_fn"
          fi
        '';
        script = ''
          exec ${lib.getExe pkgs.oauth2-proxy} --config ${cfg.out.tomlFile} --cookie-secret-file "$STATE_DIRECTORY/cookie-secret"
        '';
        unitConfig = {
          StartLimitIntervalSec = 30;
          StartLimitBurst = 5;
        };
        serviceConfig = {
          Restart = "on-failure";
          BindPaths = [ cfg.out.socketDir ];
          BindReadOnlyPaths = [
            # "${pkgs.writeText "hosts" ''127.0.0.1 localhost ${kanidmDomain}''}:/etc/hosts"
            "/etc/hosts"
            "-/etc/resolv.conf"
            "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
            cfg.out.clientSecretFile
          ];
          StateDirectory = cfg.out.fullName;
          StateDirectoryMode = vaculib.accessModeStr { user = "all"; };
          User = cfg.out.fullName;
          # https://github.com/oauth2-proxy/oauth2-proxy/issues/2141#issuecomment-1793211028
          # "To my knowledge, OAuth2 Proxy writes no files to disk." (other than the unix socket)
          # so set group & umask specifically so the socket is correct
          Group = "${cfg.out.fullName}-socket";
          UMask = vaculib.maskStr {
            user = "allow";
            group = "allow";
          };
        };
      };

      ${if cfg.out.generateClientSecret then "${cfg.out.fullName}-make-client-secret" else null} = {
        script = ''
          declare fn=${lib.escapeShellArg cfg.out.clientSecretFile}
          if ! [[ -f "$fn" ]]; then
            declare generated_secret
            generated_secret="$(${pkgs.util-linux}/bin/uuidgen -r)"

            printf '%s' "$generated_secret" > "$fn"
          fi
          chown root:${cfg.out.fullName}-client-secret "$fn"
          chmod u=rw,g=r,o= -- "$fn"
        '';
        requiredBy = [
          "kanidm.service"
          "${cfg.out.fullName}.service"
        ];
        before = [
          "kanidm.service"
          "${cfg.out.fullName}.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

      kanidm.serviceConfig.BindReadOnlyPaths = lib.mkIf cfg.configureKanidm [ cfg.out.clientSecretFile ];
    });

    services.caddy.virtualHosts = mergeWhereEach (cfg: cfg.configureCaddy) (cfg: {
      ${cfg.appDomain}.extraConfig = ''
        handle /oauth2/* {
          reverse_proxy unix/${cfg.out.socketPath} {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-Uri {uri}
          }
        }

        ${lib.optionalString cfg.out.basicAuthEnabled ''
          @has_basic_auth header Authorization "Basic *"
          handle @has_basic_auth {
            basic_auth {
              ${lib.concatMapAttrsStringSep "\n" (
                username: passwordHashes:
                lib.concatMapStringsSep "\n" (
                  passwordHash: ''${vaculib.caddyQuote username} ${vaculib.caddyQuote passwordHash}''
                ) passwordHashes
              ) cfg.basicAuthAccounts}
            }
            request_header -X-Auth-Request-Email
            request_header X-Auth-Request-Preferred-Username {http.auth.user.id}
            request_header -X-Auth-Request-User
            request_header -X-Auth-Request-Groups
            ${cfg.caddyConfig}
          }
        ''}

        handle {
          forward_auth unix/${cfg.out.socketPath} {
            uri /oauth2/auth

            header_up X-Real-IP {remote_host}

            copy_headers X-Auth-Request-Email X-Auth-Request-Preferred-Username X-Auth-Request-User X-Auth-Request-Groups

            @error status 401
            handle_response @error {
              ${lib.optionalString cfg.requireOauth ''
                redir * /oauth2/start?rd={uri}
              ''}
            }
          }

          ${cfg.caddyConfig}
        }
      '';
    });

    services.kanidm.provision = {
      enable = lib.mkIf (builtins.any (cfg: cfg.enable && cfg.configureKanidm) (
        builtins.attrValues config.vacu.oauthProxy.instances
      )) true;
      systems.oauth2 = mergeWhereEach (cfg: cfg.configureKanidm) (cfg: {
        ${cfg.name} = {
          basicSecretFile = cfg.out.clientSecretFile;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          originUrl = cfg.settings.redirect_url;
          originLanding = "https://${cfg.appDomain}/oauth2/start";
          displayName = cfg.displayName;
          scopeMaps.${cfg.out.kanidmGroup} = [
            "email"
            "openid"
          ];
        };
      });
      groups = mergeWhereEach (cfg: cfg.configureKanidm) (cfg: {
        ${cfg.out.kanidmGroup} = {
          members = [ "${cfg.out.kanidmGroup}_dynamic" ] ++ cfg.kanidmMembers;
          overwriteMembers = true;
        };
        "${cfg.out.kanidmGroup}_dynamic" = {
          overwriteMembers = false;
        };
      });
    };
  };
}
