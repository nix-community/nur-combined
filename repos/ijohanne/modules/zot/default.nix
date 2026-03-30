self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.zot;
  package = self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zot;
  settingsFormat = pkgs.formats.json { };

  hasAuthUsers = cfg.auth.users != { };
  hasMetricsUser = cfg.metrics.enable && hasAuthUsers;
  metricsPasswordFile = pkgs.writeText "zot-metrics-password" cfg.metrics.password;
  allUsers = cfg.auth.users // optionalAttrs hasMetricsUser {
    ${cfg.metrics.user} = { passwordFile = metricsPasswordFile; admin = false; };
  };
  hasUsers = allUsers != { };
  adminUsers = attrNames (filterAttrs (_: u: u.admin) allUsers);
  htpasswdPath = "${cfg.dataDir}/htpasswd";

  defaultSettings = {
    distSpecVersion = "1.1.1";
    storage = {
      rootDirectory = cfg.dataDir;
      gc = true;
      gcDelay = "1h";
      gcInterval = "6h";
    };
    http = {
      address = "0.0.0.0";
      port = "8080";
    };
    log.level = "info";
    extensions = {
      search = {
        enable = true;
        cve.updateInterval = "2h";
      };
      ui.enable = true;
      scrub = {
        enable = true;
        interval = "24h";
      };
      metrics = {
        enable = true;
        prometheus.path = "/metrics";
      };
      lint.enable = true;
    };
  };

  repopolicies = mapAttrs (_: repo: {
    inherit (repo) policies defaultPolicy anonymousPolicy;
  }) cfg.accessControl.repositories;

  authSettings = optionalAttrs hasUsers {
    http = {
      auth = {
        htpasswd.path = htpasswdPath;
        failDelay = 5;
      };
      accessControl = {
        repositories = {
          "**" = {
            defaultPolicy = cfg.accessControl.defaultPolicy;
            anonymousPolicy = cfg.accessControl.anonymousPolicy;
          };
        } // repopolicies;
      } // optionalAttrs (adminUsers != [ ]) {
        adminPolicy = {
          users = adminUsers;
          actions = cfg.accessControl.adminActions;
        };
      } // optionalAttrs hasMetricsUser {
        metrics.users = [ cfg.metrics.user ];
      };
    };
  };

  cleanKeepTag = kt: filterAttrs (_: v: v != null && v != [ ]) {
    inherit (kt) patterns mostRecentlyPushedCount mostRecentlyPulledCount pulledWithin pushedWithin;
  };

  defaultRetentionPolicy = {
    repositories = [ "**" ];
    inherit (cfg.retention.defaultPolicy) deleteReferrers deleteUntagged;
    keepTags = map cleanKeepTag cfg.retention.defaultPolicy.keepTags;
  };

  allRetentionPolicies = (map (p: {
    inherit (p) repositories deleteReferrers deleteUntagged;
    keepTags = map cleanKeepTag p.keepTags;
  }) cfg.retention.policies) ++ [ defaultRetentionPolicy ];

  retentionSettings = {
    storage.retention = {
      inherit (cfg.retention) dryRun delay;
      policies = allRetentionPolicies;
    };
  };

  effectiveSettings = lib.recursiveUpdate (lib.recursiveUpdate (lib.recursiveUpdate defaultSettings authSettings) retentionSettings) cfg.settings;
  configFile = settingsFormat.generate "zot-config.json" effectiveSettings;

  generateHtpasswd = let
    userNames = attrNames allUsers;
    commands = imap0 (i: name:
      let
        u = allUsers.${name};
        flags = if i == 0 then "-Bci" else "-Bi";
      in
      "${pkgs.apacheHttpd}/bin/htpasswd ${flags} ${escapeShellArg htpasswdPath} ${escapeShellArg name} < ${escapeShellArg (toString u.passwordFile)}"
    ) userNames;
  in
  concatStringsSep "\n" ([ "rm -f ${escapeShellArg htpasswdPath}" ] ++ commands ++ [ "chmod 600 ${escapeShellArg htpasswdPath}" ]);
in
{
  options.services.zot = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "Zot OCI container registry";
        dataDir = mkOption {
          type = types.str;
          default = "/var/lib/zot";
          description = "Directory for zot storage.";
        };
        settings = mkOption {
          type = settingsFormat.type;
          default = { };
          description = "Zot configuration rendered to JSON, merged over defaults and auth settings.";
        };
        user = mkOption {
          type = types.str;
          default = "zot";
          description = "User to run the service as.";
        };
        group = mkOption {
          type = types.str;
          default = "zot";
          description = "Group to run the service as.";
        };
        auth.users = mkOption {
          type = types.attrsOf (types.submodule {
            options = {
              passwordFile = mkOption {
                type = types.path;
                description = "Path to file containing the plaintext password (sops-compatible).";
              };
              admin = mkOption {
                type = types.bool;
                default = false;
                description = "Whether this user has admin privileges.";
              };
            };
          });
          default = { };
          description = "Declarative htpasswd users. The htpasswd file is generated at service start.";
        };
        accessControl = {
          adminActions = mkOption {
            type = types.listOf types.str;
            default = [ "read" "create" "update" "delete" ];
            description = "Actions allowed for admin users.";
          };
          defaultPolicy = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Actions allowed for any authenticated user. Empty by default (private).";
          };
          anonymousPolicy = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Actions allowed for unauthenticated users. Empty by default (private).";
          };
          repositories = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                policies = mkOption {
                  type = types.listOf (types.submodule {
                    options = {
                      users = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                        description = "Users this policy applies to.";
                      };
                      actions = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                        description = "Actions allowed for matched users.";
                      };
                    };
                  });
                  default = [ ];
                  description = "Per-user/group policy rules.";
                };
                defaultPolicy = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                  description = "Actions for any authenticated user on this repo pattern.";
                };
                anonymousPolicy = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                  description = "Actions for unauthenticated users on this repo pattern.";
                };
              };
            });
            default = { };
            description = "Per-repository access control policies. Keys are glob patterns (e.g. \"myorg/**\").";
          };
        };
        nginx = {
          enable = mkEnableOption "nginx reverse proxy for Zot";
          domain = mkOption {
            type = types.str;
            description = "Domain name for the nginx virtual host.";
          };
          forceSSL = mkOption {
            type = types.bool;
            default = true;
            description = "Force SSL for the virtual host.";
          };
          acme = mkOption {
            type = types.bool;
            default = true;
            description = "Enable ACME (Let's Encrypt) for the virtual host.";
          };
          acmeDns01 = mkOption {
            type = types.bool;
            default = false;
            description = "Use DNS-01 challenge instead of HTTP-01. Requires security.acme.defaults.dnsProvider to be configured.";
          };
        };
        retention = {
          dryRun = mkOption {
            type = types.bool;
            default = false;
            description = "Log removal actions without actually removing.";
          };
          delay = mkOption {
            type = types.str;
            default = "24h";
            description = "Only remove untagged/referrers older than this duration.";
          };
          policies = mkOption {
            type = types.listOf (types.submodule {
              options = {
                repositories = mkOption {
                  type = types.listOf types.str;
                  description = "Glob patterns matching repository names.";
                };
                deleteReferrers = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Delete manifests with a missing subject.";
                };
                deleteUntagged = mkOption {
                  type = types.bool;
                  default = true;
                  description = "Delete untagged manifests.";
                };
                keepTags = mkOption {
                  type = types.listOf (types.submodule {
                    options = {
                      patterns = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                        description = "Regex patterns matching tag names to retain.";
                      };
                      mostRecentlyPushedCount = mkOption {
                        type = types.nullOr types.int;
                        default = null;
                        description = "Retain the N most recently pushed tags.";
                      };
                      mostRecentlyPulledCount = mkOption {
                        type = types.nullOr types.int;
                        default = null;
                        description = "Retain the N most recently pulled tags.";
                      };
                      pulledWithin = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = "Retain tags pulled within this duration (e.g. \"168h\").";
                      };
                      pushedWithin = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                        description = "Retain tags pushed within this duration (e.g. \"168h\").";
                      };
                    };
                  });
                  default = [ ];
                  description = "Rules for which tags to retain. Tags not matching any rule are removed.";
                };
              };
            });
            default = [ ];
            description = "Repo-specific retention policies, prepended before the default catch-all. First match wins.";
          };
          defaultPolicy = {
            deleteReferrers = mkOption {
              type = types.bool;
              default = false;
              description = "Delete manifests with a missing subject in the catch-all policy.";
            };
            deleteUntagged = mkOption {
              type = types.bool;
              default = true;
              description = "Delete untagged manifests in the catch-all policy.";
            };
            keepTags = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  patterns = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                    description = "Regex patterns matching tag names to retain.";
                  };
                  mostRecentlyPushedCount = mkOption {
                    type = types.nullOr types.int;
                    default = null;
                    description = "Retain the N most recently pushed tags.";
                  };
                  mostRecentlyPulledCount = mkOption {
                    type = types.nullOr types.int;
                    default = null;
                    description = "Retain the N most recently pulled tags.";
                  };
                  pulledWithin = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Retain tags pulled within this duration.";
                  };
                  pushedWithin = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Retain tags pushed within this duration.";
                  };
                };
              });
              default = [{ patterns = [ ".*" ]; }];
              description = "Tag retention rules for the default catch-all policy. Default keeps all tags.";
            };
          };
        };
        metrics = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable a dedicated metrics user for prometheus scraping.";
          };
          user = mkOption {
            type = types.str;
            default = "prometheus";
            description = "Username for the metrics scraping user.";
          };
          password = mkOption {
            type = types.str;
            default = "prometheus";
            description = "Password for the metrics scraping user.";
          };
        };
        enableLocalScraping = mkEnableOption "scraping by local prometheus";
        grafanaDashboard = mkEnableOption "Grafana dashboard provisioning for Zot";
      };
    };
    default = { };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };
    users.groups.${cfg.group} = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.zot = {
      description = "Zot OCI Container Registry";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      preStart = optionalString hasUsers generateHtpasswd;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getBin package}/bin/zot serve ${configFile}";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        LimitNOFILE = 500000;
        PrivateTmp = true;
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };

    services.prometheus.scrapeConfigs = mkIf cfg.enableLocalScraping [
      {
        job_name = "zot";
        honor_labels = true;
        metrics_path = effectiveSettings.extensions.metrics.prometheus.path or "/metrics";
        basic_auth = mkIf cfg.metrics.enable {
          username = cfg.metrics.user;
          password = cfg.metrics.password;
        };
        static_configs = [{
          targets = [ "${effectiveSettings.http.address}:${effectiveSettings.http.port}" ];
        }];
      }
    ];

    services.grafana.provision.dashboards.settings.providers = mkIf cfg.grafanaDashboard [
      {
        name = "zot";
        options.path = pkgs.runCommand "zot-dashboards" { } ''
          mkdir -p $out
          cp ${./dashboard.json} $out/zot.json
        '';
      }
    ];

    services.nginx.virtualHosts.${cfg.nginx.domain} = mkIf cfg.nginx.enable {
      forceSSL = cfg.nginx.forceSSL;
      enableACME = cfg.nginx.acme;
      acmeRoot = mkIf (cfg.nginx.acme && cfg.nginx.acmeDns01) null;
      locations."/metrics" = {
        return = "403";
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:${effectiveSettings.http.port}/";
        extraConfig = ''
          client_max_body_size 0;
          proxy_buffering off;
          chunked_transfer_encoding on;
        '';
      };
    };
  };
}
