{ config, options, pkgs, lib, ... }: with lib; let
  cfg = config.services.matrix-appservices;
  inherit (config.services) matrix-synapse;
  matrix-appservices = config.lib.matrix-appservices;
  appservices = attrValues cfg;
  arc = import ../../canon.nix { inherit pkgs; };
  toFunctor = lib.toFunctor or arc.lib.toFunctor;
  json = lib.json or arc.lib.json;
  inherit (import ./matrix-common.nix { inherit lib pkgs; }) registrationModule;
  registrationType = types.submodule registrationModule;
  hasMutableState = options ? system.mutableState;
  mkDefaultOverride = mkOverride 1250;
  appserviceModule = { name, config, options, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      createUser = mkOption {
        type = types.bool;
        default = config.user == config.name;
      };
      user = mkOption {
        type = types.str;
        default = config.name;
      };
      group = mkOption {
        type = types.str;
        default = if matrix-synapse.enable then "matrix-synapse" else config.user;
      };
      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/${config.name}";
      };
      database = {
        type = mkOption {
          type = types.enum [ null "sqlite3" "postgresql" ];
          default = null;
        };
        name = mkOption {
          type = types.str;
          default = if config.database.type == "postgresql"
            then replaceStrings [ "-" ] [ "_" ] config.name
            else config.name;
        };
        # for postgresql only...
        user = mkOption {
          type = types.str;
          default = config.user;
        };
        password = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        host = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        postgresql.uri = mkOption {
          type = types.str;
        };
      };
      name = mkOption {
        type = types.str;
        default = name;
      };
      package = mkOption {
        type = types.package;
      };
      exec = mkOption {
        type = types.str;
        default = "${config.package}/bin/${config.name}";
      };
      cmdargs = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      cmdline = mkOption {
        type = types.str;
      };
      registration = mkOption {
        type = registrationType;
        default = { };
      };
      setSystemdService = mkOption {
        type = unmerged.types.attrs;
      };
    };
    config = {
      package = mkIf (pkgs ? ${config.name}) (mkOptionDefault pkgs.${config.name});
      cmdline = mkOptionDefault "${config.exec} ${escapeShellArgs config.cmdargs}";
      registration = {
        configuration = {
          inherit (config) name;
          combinedPath = "/run/${config.name}/registration.yaml";
        };
      };
      database.postgresql.uri = let
        pw = optionalString (config.database.password != null) ":${config.database.password}";
        host = if config.database.host == null
          then "%2Frun%2Fpostgresql"
          else config.database.host;
      in mkOptionDefault "postgres://${config.database.user}${pw}@${host}/${config.database.name}";
      setSystemdService = {
        serviceConfig = mkMerge [ {
          ExecStart = config.cmdline;
          WorkingDirectory = config.dataDir;
          RuntimeDirectory = [ config.name ];
        } (mkIf config.createUser {
          User = config.user;
          Group = config.group;
        }) ];
        requisite = mkIf (matrix-synapse.enable && matrix-synapse.appservices.${name}.enable) [ "matrix-synapse.service" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        preStart = ''
          ${config.registration.configuration.out.generate}
        '';
      };
    };
  };
  appserviceType = types.submodule appserviceModule;
  mapService = cfg: unmerged.mergeAttrs cfg.setSystemdService;
  mapPostgresql = cfg: {
    ensureUsers = singleton {
      name = cfg.database.user;
      ensurePermissions = {
        "DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
      };
    };
    ensureDatabases = singleton cfg.database.name;
  };
in {
  options.services.matrix-appservices = mkOption {
    type = types.attrsOf appserviceType;
    default = { };
  };
  config = {
    services.matrix-appservices = {
      mautrix-hangouts = { config, ... }: {
        imports = [
          matrix-appservices.mautrix-python
          matrix-appservices.mautrix-python.alembic
        ];
        options = {
          homeserver = {
            asmux = mkOption {
              type = types.bool;
              default = false;
            };
          };
          hangouts = {
            deviceName = mkOption {
              type = types.str;
              default = "Mautrix-Hangouts bridge";
            };
          };
          metrics = {
            listenPort = mkOption {
              type = types.port;
              default = 8000;
            };
          };
        };
        config = {
          package = mkDefault pkgs.mautrix-hangouts or arc.pkgs.mautrix-hangouts;
          registration = {
            id = mkDefaultOverride "hangouts";
            namespaces.users = mkDefault [ {
              regex = "@hangouts_.+";
            } ];
          };
          configuration = {
            settings = {
              homeserver = {
                inherit (config.homeserver) asmux;
              };
              hangouts = {
                device_name = config.hangouts.deviceName;
              };
              metrics = {
                listen_port = config.metrics.listenPort;
              };
            };
          };
          appservice = {
            port = mkDefaultOverride 29320;
            bot = {
              username = mkDefaultOverride "hangoutsbot";
              displayname = mkDefaultOverride "Hangouts bridge bot";
              avatar = mkDefaultOverride "mxc://maunium.net/FBXZnpfORkBEruORbikmleAy";
            };
          };
          bridge = mapAttrs (_: mkOptionDefault) {
            username_template = "hangouts_{userid}";
            displayname_template = "{full_name} (Hangouts)";
            community_template = null;
            command_prefix = "!hg";
            initial_chat_sync = 10;
            invite_own_puppet_to_pm = false;
            sync_with_custom_puppets = config.registration.pushEphemeral != true;
            sync_direct_chat_list = false;
            double_puppet_allow_discovery = false;
            update_avatar_initial_sync = true;
            delivery_receipts = false;
            resend_bridge_info = false;
            unimportant_bridge_notices = true;
            double_puppet_server_map = { };
            login_shared_secret_map = { };
          } // {
            permissions = mkMerge [
              { }
              (mkIf matrix-synapse.enable {
                ${matrix-synapse.settings.server_name} = mkOptionDefault "user";
                #"@admin:example.com" = "admin";
              })
            ];
            encryption = {
              allow = mkOptionDefault false;
              default = mkOptionDefault false;
              database = mkOptionDefault "default";
              key_sharing = mapAttrs (_: mkOptionDefault) {
                allow = false;
                require_cross_signing = false;
                require_verification = true;
              };
            };
            backfill = mapAttrs (_: mkOptionDefault) {
              invite_own_puppet = true;
              initial_limit = 0;
              missed_limit = 100;
              disable_notifications = false;
            };
            reconnect = mapAttrs (_: mkOptionDefault) {
              max_retries = 30;
              retry_backoff_base = 1.5;
            };
            web.auth = mapAttrs (_: mkOptionDefault) {
              public = "http://example.com/login/";
              prefix = "/login";
              shared_secret = "generate";
            };
          };
        };
      };
      mautrix-googlechat = { config, ... }: {
        imports = [
          matrix-appservices.mautrix-python
        ];
        options = {
          homeserver = {
            asmux = mkOption {
              type = types.bool;
              default = false;
            };
          };
          googlechat = {
            deviceName = mkOption {
              type = types.str;
              default = "Mautrix-Google Chat bridge";
            };
          };
          metrics = {
            listenPort = mkOption {
              type = types.port;
              default = 8000;
            };
          };
        };
        config = {
          package = mkDefault pkgs.mautrix-googlechat or arc.pkgs.mautrix-googlechat;
          registration = {
            id = mkDefaultOverride "googlechat";
            namespaces.users = mkDefault [ {
              regex = "@googlechat_.+";
            } ];
          };
          configuration = {
            settings = {
              homeserver = {
                inherit (config.homeserver) asmux;
              };
              hangouts = {
                device_name = config.googlechat.deviceName;
              };
              metrics = {
                listen_port = config.metrics.listenPort;
              };
            };
          };
          appservice = {
            port = mkDefaultOverride 29320;
            bot = {
              username = mkDefaultOverride "googlechatbot";
              displayname = mkDefaultOverride "Google Chat bridge bot";
              avatar = mkDefaultOverride "mxc://maunium.net/BDIWAQcbpPGASPUUBuEGWXnQ";
            };
            database.opts = mapAttrs (_: mkOptionDefault) {
              min_size = 5;
              max_size = 10;
            };
          };
          database.type = mkDefault "postgresql";
          bridge = mapAttrs (_: mkOptionDefault) {
            username_template = "googlechat_{userid}";
            displayname_template = "{full_name} (Google Chat)";
            command_prefix = "!gc";
            initial_chat_sync = 10;
            invite_own_puppet_to_pm = false;
            sync_with_custom_puppets = config.registration.pushEphemeral != true;
            sync_direct_chat_list = false;
            double_puppet_allow_discovery = false;
            update_avatar_initial_sync = true;
            delivery_receipts = false;
            resend_bridge_info = false;
            unimportant_bridge_notices = true;
            disable_bridge_notices = false;
            double_puppet_server_map = { };
            login_shared_secret_map = { };
          } // {
            permissions = mkMerge [
              { }
              (mkIf matrix-synapse.enable {
                ${matrix-synapse.settings.server_name} = mkOptionDefault "user";
                #"@admin:example.com" = "admin";
              })
            ];
            encryption = {
              allow = mkOptionDefault false;
              default = mkOptionDefault false;
              key_sharing = mapAttrs (_: mkOptionDefault) {
                allow = false;
                require_cross_signing = false;
                require_verification = true;
              };
            };
            backfill = mapAttrs (_: mkOptionDefault) {
              invite_own_puppet = true;
              initial_thread_limit = 10;
              initial_thread_reply_limit = 500;
              initial_nonthread_limit = 100;
              missed_event_limit = 5000;
              missed_event_page_size = 100;
              disable_notifications = false;
            };
            reconnect = mapAttrs (_: mkOptionDefault) {
              max_retries = 4;
              retry_backoff_base = 1.5;
            };
            web.auth = mapAttrs (_: mkOptionDefault) {
              public = "https://example.com/login/";
              prefix = "/login";
              shared_secret = "generate";
            };
          };
        };
      };
      mautrix-signal = {
        package = mkDefault pkgs.mautrix-signal;
      };
      mautrix-telegram = {
        package = mkDefault pkgs.mautrix-telegram;
      };
      mautrix-whatsapp = { config, ... }: {
        imports = [ matrix-appservices.mautrix ];
        options = {
          homeserver = {
            address = mkOption {
              type = types.str;
            };
            domain = mkOption {
              type = types.str;
            };
            asmux = mkOption {
              type = with types; nullOr bool;
              default = null;
            };
            statusEndpoint = mkOption {
              type = with types; nullOr str;
              default = null;
            };
          };
          appservice = {
            hostname = mkOption {
              type = types.str;
              default = "0.0.0.0";
            };
            port = mkOption {
              type = types.port;
              default = 29318;
            };
            database = {
              type = mkOption {
                type = types.enum [ "sqlite3" "postgres" ];
              };
              uri = mkOption {
                type = types.str;
              };
              maxOpenConns = mkOption {
                type = types.int;
                default = 20;
              };
              maxIdleConns = mkOption {
                type = types.int;
                default = 2;
              };
            };
            stateStore = mkOption {
              type = types.str;
              default = "./mx-state.json";
            };
            provisioning = {
              prefix = mkOption {
                type = types.str;
                default = "/_matrix/provision/v1";
              };
              sharedSecret = mkOption {
                type = with types; either (enum [ "disable" ]) str;
                default = "disable";
              };
            };
            bot = mkOption {
              type = types.submodule matrix-appservices.mautrix.bot;
            };
          };
          whatsapp = {
            osName = mkOption {
              type = types.str;
              default = "Mautrix-WhatsApp bridge";
            };
            browserName = mkOption {
              type = types.str;
              default = "mx-wa";
            };
          };
          bridge = mkOption {
            type = json.types.attrs; # TODO?
          };
          logging = mkOption {
            type = types.submodule matrix-appservices.mautrix-go.logging;
            default = { };
          };
        };
        config = {
          package = mkDefault pkgs.mautrix-whatsapp;
          registration = {
            id = mkDefaultOverride "whatsapp";
            senderLocalpart = mkDefaultOverride config.appservice.bot.username;
            port = mkDefaultOverride config.appservice.port;
            namespaces.users = mkDefault [ {
              regex = "^@whatsapp_[0-9]+:.*$";
            } ];
          };
          homeserver = mkIf matrix-synapse.enable {
            address = mkOptionDefault matrix-synapse.settings.public_baseurl;
            domain = mkOptionDefault matrix-synapse.settings.server_name;
          };
          appservice.bot = {
            username = mkDefaultOverride "whatsappbot";
            displayname = mkDefaultOverride "WhatsApp bridge bot";
            avatar = mkDefaultOverride "mxc://maunium.net/NeXNQarUbrlYBiPCpprYsRqr";
          };
          database.type = mkDefaultOverride "sqlite3";
          appservice.database = {
            type = mkMerge [
              (mkIf (config.database.type == "sqlite3") (mkOptionDefault "sqlite3"))
              (mkIf (config.database.type == "postgresql") (mkOptionDefault "postgres"))
            ];
            uri = mkMerge [
              (mkIf (config.database.type == "sqlite3") (mkDefaultOverride "${config.database.name}.db"))
              (mkIf (config.database.type == "postgresql") (mkDefaultOverride config.database.postgresql.uri))
            ];
          };
          bridge = mapAttrs (_: mkOptionDefault) {
            username_template = "whatsapp_{{.}}";
            displayname_template = "{{if .Notify}}{{.Notify}}{{else}}{{.Jid}}{{end}} (WA)";
            community_template = null;
            connection_timeout = 20;
            fetch_message_on_timeout = false;
            delivery_receipts = false;
            max_connection_attempts = 3;
            connection_retry_delay = -1;
            report_connection_retry = true;
            aggressive_reconnect = false;
            chat_list_wait = 30;
            portal_sync_wait = 600;
            user_message_buffer = 1024;
            portal_message_buffer = 128;
            initial_chat_sync_count = 10;
            initial_history_fill_count = 20;
            initial_history_disable_notifications = false;
            recovery_chat_sync_limit = -1;
            recovery_history_backfill = true;
            chat_meta_sync = true;
            user_avatar_sync = true;
            bridge_matrix_leave = true;
            sync_max_chat_age = 259200;
            sync_with_custom_puppets = true;
            sync_direct_chat_list = false;
            default_bridge_receipts = true;
            default_bridge_presence = true;
            login_shared_secret = null;
            invite_own_puppet_for_backfilling = true;
            private_chat_portal_meta = false;
            bridge_notices = true;
            resend_bridge_info = false;
            mute_bridging = false;
            archive_tag = null;
            pinned_tag = null;
            tag_only_on_create = true;
            enable_status_broadcast = true;
            whatsapp_thumbnail = false;
            allow_user_invite = false;
            command_prefix = "!wa";
          } // {
            call_notices = mapAttrs (_: mkOptionDefault) {
              start = true;
              end = true;
            };
            encryption = {
              allow = mkOptionDefault false;
              default = mkOptionDefault false;
              key_sharing = mapAttrs (_: mkOptionDefault) {
                allow = false;
                require_cross_signing = false;
                require_verification = true;
              };
            };
            permissions = mkMerge [
              {
                "*" = "relaybot";
              }
              (mkIf matrix-synapse.enable {
                ${matrix-synapse.settings.server_name} = mkOptionDefault "user";
                #"@admin:example.com" = "admin";
              })
            ];
            relaybot = {
              enabled = mkOptionDefault false;
              management = mkOptionDefault "!foo:example.com";
              invites = mkOptionDefault [];
              message_formats = mapAttrs (_: mkOptionDefault) {
                "m.text" = "<b>{{ .Sender.Displayname }}</b>: {{ .Message }}";
                "m.notice" = "<b>{{ .Sender.Displayname }}</b>: {{ .Message }}";
                "m.emote" = "* <b>{{ .Sender.Displayname }}</b> {{ .Message }}";
                "m.file" = "<b>{{ .Sender.Displayname }}</b> sent a file";
                "m.image" = "<b>{{ .Sender.Displayname }}</b> sent an image";
                "m.audio" = "<b>{{ .Sender.Displayname }}</b> sent an audio file";
                "m.video" = "<b>{{ .Sender.Displayname }}</b> sent a video";
                "m.location" = "<b>{{ .Sender.Displayname }}</b> sent a location";
              };
            };
          };
          configuration = {
            settings = {
              homeserver = {
                inherit (config.homeserver) address domain asmux;
                status_endpoint = config.homeserver.statusEndpoint;
              };
              appservice = {
                inherit (config.appservice) hostname port;
                address = config.registration.url;
                database = {
                  inherit (config.appservice.database) type uri;
                  max_open_conns = config.appservice.database.maxOpenConns;
                  max_idle_conns = config.appservice.database.maxIdleConns;
                };
                state_store_path = config.appservice.stateStore;
                inherit (config.registration) id;
                bot = {
                  username = config.registration.senderLocalpart;
                  inherit (config.appservice.bot) displayname avatar;
                };
              };
              whatsapp = {
                os_name = config.whatsapp.osName;
                browser_name = config.whatsapp.browserName;
              };
              inherit (config) bridge;
              logging = config.logging.out.json;
            };
            sensitiveSettings = {
              appservice = {
                as_token = config.registration.token.appservice;
                hs_token = config.registration.token.homeserver;
              };
            };
          };
        };
      };
      matrix-appservice-irc = { config, ... }: {
        imports = [ matrix-appservices.matrix-appservice-bridge ];
        config = {
          package = mkDefault pkgs.matrix-appservice-irc;
          port = mkOptionDefault 8090;
        };
      };
      matrix-appservice-discord = { config, ... }: {
        imports = [ matrix-appservices.matrix-appservice-bridge ];
        config = {
          package = mkDefault pkgs.matrix-appservice-discord;
          port = mkOptionDefault 9005;
          registration = {
            id = mkDefaultOverride "discord-bridge";
            senderLocalpart = mkDefaultOverride "_discord_bot";
            namespaces = {
              aliases = mkDefault [ {
                regex = "#_discord_.*";
              } ];
              users = mkDefault [ {
                regex = "@_discord_.*";
              } ];
            };
            protocols = mkDefault [ "discord" ];
          };
        };
      };
      mx-puppet-discord = { config, ... }: {
        imports = [ matrix-appservices.mx-puppet ];
        options = {
          presence = {
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
            interval = mkOption {
              type = types.int;
              default = 500;
            };
          };
        };
        config = {
          package = mkDefault pkgs.mx-puppet-discord;
          registrationPrefix = mkOptionDefault "_discordpuppet_";
          bridge = {
            port = mkDefaultOverride 8434;
            displayname = mkDefaultOverride "Discord Puppet Bridge";
            enableGroupSync = mkDefaultOverride true;
          };
          namePatterns.userOverride = mkDefaultOverride ":displayname";
          configuration.settings = {
            presence = {
              inherit (config.presence) enabled interval;
            };
          };
          registration = {
            id = mkDefaultOverride "discord-puppet";
            #protocols = mkDefault [ "discord" ];
          };
        };
      };
      heisenbridge = { config, ... }: {
        options = {
          homeserverUrl = mkOption {
            type = types.str;
            #default = "http://localhost:8008";
          };
          owner = mkOption {
            type = with types; nullOr str;
            default = null;
            example = "@user:homeserver";
          };
          logLevel = mkOption {
            type = types.enum [ "warning" "info" "debug" ];
            default = "warning";
          };
          listen = {
            address = mkOption {
              type = types.str;
              default = "127.0.0.1";
            };
            port = mkOption {
              type = types.port;
              default = 9898;
            };
          };
          identd = {
            enable = mkEnableOption "identd service";
            port = mkOption {
              type = types.port;
              default = 113;
            };
          };
        };
        config = {
          package = mkDefault pkgs.heisenbridge;
          homeserverUrl = mkIf matrix-synapse.enable (mkOptionDefault matrix-synapse.settings.public_baseurl);
          registration = {
            senderLocalpart = mkDefaultOverride "heisenbridge";
            port = mkDefaultOverride config.listen.port;
            namespace.users = mkDefault [ {
              regex = "@irc_.*";
            } ];
          };
          cmdargs = mkMerge [
            [
              "-c" config.registration.out
              "-l" config.listen.address
              "-p" (toString config.listen.port)
              "--identd-port" (toString config.identd.port)
            ]
            (mkIf config.identd.enable [ "-i" ])
            (mkIf (config.owner != null) [ "-o" config.owner ])
            (mkIf (config.logLevel == "info") [ "-v" ])
            (mkIf (config.logLevel == "debug") [ "-vv" ])
            (mkAfter [ config.homeserverUrl ])
          ];
        };
      };
    };
    systemd.services = mapAttrs' (_: cfg: nameValuePair cfg.name (mapService cfg)) (filterAttrs (_: cfg: cfg.enable) cfg);
    users = let
      services = filter (cfg: cfg.enable && cfg.createUser) appservices;
    in {
      users = listToAttrs (map (cfg: nameValuePair cfg.user {
        home = cfg.dataDir;
        createHome = true;
        group = cfg.group;
        isSystemUser = true;
      }) services);
      groups = listToAttrs (map (cfg: nameValuePair cfg.group {
        #members = [ cfg.user ];
      }) services);
    };
    system = optionalAttrs hasMutableState {
      mutableState.services = mapListToAttrs (cfg: nameValuePair cfg.name {
        # TODO: databases
        enable = mkDefault cfg.enable;
        backup.frequency.days = mkDefault 5; # these get noisy
        owner = cfg.user;
        group = cfg.group;
        paths = singleton {
          path = cfg.dataDir;
        };
        databases.postgresql = mkIf (cfg.database.type == "postgresql") [ cfg.database.name ];
      }) (attrValues cfg);
    };
    services.postgresql = mkMerge (mapAttrsToList (_: cfg: mapPostgresql cfg) (
      filterAttrs (_: cfg: cfg.enable && cfg.database.type == "postgresql") cfg
    ));
    lib.matrix-appservices = {
      yaml-common = { config, ... }: {
        options = {
          configuration = mkOption {
            type = sensitive.type;
          };
        };
        config = {
          configuration = {
            name = "${config.name}-config";
            format = "yaml";
            combinedPath = "/run/${config.name}/config.yaml";

            _module.args = {
              inherit pkgs;
            };
          };
          cmdargs = [
            "-c" config.configuration.path
          ];
          setSystemdService.preStart = ''
            ${config.configuration.out.generate}
          '';
        };
      };
      matrix-appservice-bridge = { config, ... }: {
        imports = [
          matrix-appservices.yaml-common
        ];
        options = {
          port = mkOption {
            type = types.port;
          };
        };
        config = {
          registration.port = mkDefaultOverride config.port;
          cmdargs = [
            "-f" config.registration.configuration.path
            "-p" (toString config.port)
          ];
        };
      };
      mautrix = toFunctor ({ config, ... }: {
        imports = [
          matrix-appservices.yaml-common
        ];
      }) // {
        bot = { ... }: {
          options = {
            username = mkOption {
              type = types.str;
            };
            displayname = mkOption {
              type = types.str;
            };
            avatar = mkOption {
              type = types.str;
            };
          };
        };
      };
      mautrix-go = toFunctor ({ config, ... }: {
        imports = [
          matrix-appservices.mautrix
        ];
        options = {
          homeserverDomain = mkOption {
            type = types.str;
          };
          homeserverUrl = mkOption {
            type = types.str;
          };
          registrationPath = mkOption {
            type = types.path;
            default = config.registration.out;
          };
          host = {
            hostname = mkOption {
              type = types.str;
            };
            port = mkOption {
              type = types.port;
            };
            tlsKey = mkOption {
              type = with types; nullOr path;
              default = null;
            };
            tlsCert = mkOption {
              type = with types; nullOr path;
              default = null;
            };
          };
          logging = mkOption {
            type = types.submodule matrix-appservices.mautrix-go.logging;
            default = { };
          };
        };
        config = {
          registration.port = mkDefaultOverride config.host.port;
          configuration.settings = {
            homeserver_domain = config.homeserverDomain;
            homeserver_url = config.homeserverUrl;
            registration = config.registrationPath;
            host = {
              inherit (config.host) hostname port;
              tls_key = mkIf (config.tlsKey != null) config.host.tlsKey;
              tls_cert = mkIf (config.tlsCert != null) config.host.tlsCert;
            };
            logging = config.logging.out.json;
          };
        };
      }) // {
        logging = { config, ... }: {
          options = {
            directory = mkOption {
              type = types.str;
              default = "./logs";
            };
            fileNameFormat = mkOption {
              type = types.str;
              default = "{{.Date}}-{{.Index}}.log";
            };
            fileDateFormat = mkOption {
              type = types.str;
              default = "2006-01-02";
            };
            fileMode = mkOption {
              type = types.int;
              default = bitShl 6 6; # octal 0600
            };
            timestampFormat = mkOption {
              type = types.str;
              default = "Jan _2, 2006 15:04:05";
            };
            printLevel = mkOption {
              type = types.enum [ "trace" "debug" "info" "warn" "error" "fatal" ];
              default = "info";
            };
            printJson = mkOption {
              type = types.bool;
              default = false;
            };
            fileJson = mkOption {
              type = types.bool;
              default = false;
            };
            out.json = mkOption {
              type = types.unspecified;
            };
          };
          config.out.json = {
            inherit (config) directory;
            file_name_format = config.fileNameFormat;
            file_date_format = config.fileDateFormat;
            file_mode = config.fileMode;
            timestamp_format = config.timestampFormat;
            print_level = config.printLevel;
            print_json = config.printJson;
            file_json = config.fileJson;
          };
        };
      };
      mautrix-python = toFunctor ({ config, options, ... }: {
        imports = [
          matrix-appservices.mautrix
        ];
        options = {
          homeserver = {
            address = mkOption {
              type = types.str;
            };
            domain = mkOption {
              type = types.str;
            };
            verifySsl = mkOption {
              type = types.bool;
              default = true;
            };
            httpRetryCount = mkOption {
              type = types.int;
              default = 4;
            };
            statusEndpoint = mkOption {
              type = with types; nullOr unspecified;
              default = null;
            };
            messageSendCheckpointEndpoint = mkOption {
              type = with types; nullOr unspecified;
              default = null;
            };
          };
          appservice = {
            hostname = mkOption {
              type = types.str;
              default = "0.0.0.0";
            };
            port = mkOption {
              type = types.port;
              default = 8080;
            };
            maxBodySize = mkOption {
              type = types.int;
              default = 1;
            };
            database = {
              uri = mkOption {
                type = types.str;
              };
              opts = mkOption {
                type = with types; attrsOf unspecified;
                default = { };
              };
            };
            communityId = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            bot = mkOption {
              type = types.submodule matrix-appservices.mautrix.bot;
              default = { };
            };
          };
          metrics = {
            enabled = mkOption {
              type = types.bool;
              default = false;
            };
            listen = mkOption {
              type = types.str;
              default = "127.0.0.1:8001";
            };
          };
          manhole = {
            enabled = mkOption {
              type = types.bool;
              default = false;
            };
            path = mkOption {
              type = types.path;
              default = "/var/tmp/${config.name}.manhole";
            };
            whitelist = mkOption {
              type = with types; listOf int;
              default = singleton 0;
            };
          };
          bridge = mkOption {
            type = json.types.attrs; # TODO?
          };
          logging = mkOption {
            # https://docs.python.org/3.6/library/logging.config.html#configuration-dictionary-schema
            type = json.types.attrs; # TODO?
          };
        };
        config = {
          homeserver = mkIf matrix-synapse.enable {
            address = mkOptionDefault matrix-synapse.settings.public_baseurl;
            domain = mkOptionDefault matrix-synapse.settings.server_name;
          };
          database.type = mkDefaultOverride "sqlite3";
          appservice.database.uri = mkMerge [
            (mkIf (config.database.type == "postgresql") (mkOptionDefault config.database.postgresql.uri))
            (mkIf (config.database.type == "sqlite3") (mkOptionDefault "sqlite:///${config.database.name}.db"))
          ];
          registration = {
            port = mkDefaultOverride config.appservice.port;
            senderLocalpart = mkDefaultOverride "_${config.appservice.bot.username}";
            namespaces = let
              token = "regexplaceholder1234";
              replaceFormat = id: pattern: let
                escaped = escapeRegex (replaceStrings [ "{${id}}" ] [ token ] pattern);
              in replaceStrings [ token ] [ ".*" ] escaped;
            in {
              aliases = mkIf (config.bridge.alias_template or null != null) [
                {
                  regex = replaceFormat "groupname" "@${config.bridge.alias_template}:${config.homeserver.domain}";
                }
              ];
              users = [
                {
                  regex = replaceFormat "userid" "@${config.bridge.username_template}:${config.homeserver.domain}";
                  groupId = config.appservice.communityId;
                }
                {
                  regex = escapeRegex "@${config.appservice.bot.username}:${config.homeserver.domain}";
                }
              ];
            };
          };
          configuration = {
            settings = {
              homeserver = {
                inherit (config.homeserver) address domain;
                verify_ssl = config.homeserver.verifySsl;
                http_retry_count = config.homeserver.httpRetryCount;
                status_endpoint = config.homeserver.statusEndpoint;
                message_send_checkpoint_endpoint = config.homeserver.messageSendCheckpointEndpoint;
              };
              appservice = {
                address = config.registration.url;
                hostname = config.appservice.hostname;
                port = config.appservice.port;
                max_body_size = config.appservice.maxBodySize;
                database = config.appservice.database.uri;
                database_opts = config.appservice.database.opts;

                inherit (config.registration) id;
                bot_username = config.appservice.bot.username;
                bot_displayname = config.appservice.bot.displayname;
                bot_avatar = config.appservice.bot.avatar;
                ephemeral_events = config.registration.pushEphemeral;
                community_id = config.appservice.communityId;
              };
              metrics = {
                inherit (config.metrics) enabled listen;
              };
              manhole = {
                inherit (config.manhole) enabled path whitelist;
              };
              bridge = removeAttrs config.bridge [ "login_shared_secret_map" ];
              inherit (config) logging;
            };
            sensitiveSettings = {
              bridge = {
                inherit (config.bridge) login_shared_secret_map;
              };
              appservice = {
                as_token = config.registration.token.appservice;
                hs_token = config.registration.token.homeserver;
              };
            };
          };
          bridge = { };
          logging = {
            version = mkOptionDefault 1;
            formatters = let
              format = "[%(asctime)s] [%(levelname)s@%(name)s] %(message)s";
            in {
              colored = {
                "()" = {
                  mautrix-googlechat = "mautrix_googlechat.util.ColorFormatter";
                  mautrix-hangouts = "mautrix_hangouts.util.ColorFormatter";
                }.${config.name};
                inherit format;
              };
              normal = {
                inherit format;
              };
            };
            handlers = {
              file = {
                class = "logging.handlers.RotatingFileHandler";
                formatter = "normal";
                filename = "./mautrix-${config.registration.id}.log";
                maxBytes = 10485760;
                backupCount = 10;
              };
              console = {
                class = "logging.StreamHandler";
                formatter = "colored";
              };
            };
            loggers = {
              mau.level = mkDefault "DEBUG";
              maugclib.level = mkDefault "INFO";
              hangups.level = mkDefault "INFO";
              aiohttp.level = mkDefault "INFO";
            };
            root = {
              level = mkDefault "DEBUG";
              handlers = mkDefault [ "file" "console" ];
            };
          };
          cmdargs = let
            pythonPackageName = replaceStrings [ "-" ] [ "_" ] config.name;
            mautrixExample = [ "-b" "${config.package}/${config.package.pythonModule.sitePackages}/${config.package.pythonPackage or pythonPackageName}/example-config.yaml" ];
            hasMautrixExample = options.package.isDefined && config.package ? pythonModule;
          in mkMerge [
            (mkIf hasMautrixExample mautrixExample)
          ];
        };
      }) // {
        alembic = { config, options, ... }: {
          options = {
            alembic = {
              enable = mkEnableOption "alembic database migration" // {
                default = options.package.isDefined && config.package ? alembic;
              };
              package = mkOption {
                type = types.package;
                default = pkgs.python3Packages.alembic;
              };
              exec = mkOption {
                type = types.str;
                default = "${config.alembic.package}/bin/alembic";
              };
              configPath = mkOption {
                type = types.path;
              };
              configDirectory = mkOption {
                type = types.path;
              };
              upgradeScript = mkOption {
                type = types.lines;
              };
            };
          };
          config = {
            alembic = mkMerge [ {
              upgradeScript = mkMerge [
                (mkBefore ''
                  install -m0600 ${config.configuration.path} ./config.yaml
                  ln -Tsf ${config.alembic.configDirectory} ./alembic
                '')
                ''
                  ${config.alembic.exec} \
                    -x config=./config.yaml \
                    -c ${config.alembic.configPath} \
                    upgrade head
                ''
              ];
            } (mkIf options.package.isDefined {
              package = mkIf (config.package ? alembic) (mkDefault config.package.alembic);
              configPath = mkOptionDefault "${config.package}/alembic.ini";
              configDirectory = mkOptionDefault "${config.package}/alembic";
            }) ];
            setSystemdService.preStart = mkIf config.alembic.enable config.alembic.upgradeScript;
          };
        };
      };
      mx-puppet = { config, ... }: {
        imports = [
          matrix-appservices.yaml-common
        ];
        options = {
          registrationPrefix = mkOption {
            type = types.str;
          };
          bridge = {
            bindAddress = mkOption {
              type = types.str;
              default = "localhost";
            };
            port = mkOption {
              type = types.port;
            };
            domain = mkOption {
              type = types.str;
            };
            homeserverUrl = mkOption {
              type = types.str;
            };
            mediaUrl = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            loginSharedSecretMap = mkOption {
              type = with types; attrsOf str;
              default = { };
            };
            displayname = mkOption {
              type = with types; nullOr str;
              default = null;
            };
            avatarUrl = mkOption {
              type = with types; nullOr str;
              default = null;
            };
            enableGroupSync = mkOption {
              type = types.bool;
              default = false;
            };
            stripHomeservers = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
          };
          logging = let
            loggingLevelType = types.enum [ "error" "warn" "info" "verbose" "debug" "silly" ];
            loggingInterfaceModuleConfig = { ... }: {
              options = {
                module = mkOption {
                  type = types.str;
                };
                regex = mkOption {
                  type = types.str;
                };
              };
            };
            loggingInterfaceConfig = { ... }: {
              options = {
                level = mkOption {
                  type = loggingLevelType;
                  default = "info";
                };
                enabled = mkOption {
                  type = with types; listOf (either str loggingInterfaceModuleConfig);
                  default = [ ];
                };
                disabled = mkOption {
                  type = with types; listOf (either str loggingInterfaceModuleConfig);
                  default = [ ];
                };
              };
            };
            loggingFileConfig = { ... }: {
              imports = [ loggingInterfaceConfig ];
              options = {
                file = mkOption {
                  type = types.str;
                };
                maxFiles = mkOption {
                  type = types.str;
                  default = "14d";
                };
                maxSize = mkOption {
                  type = with types; either str int;
                  default = "50m";
                };
                datePattern = mkOption {
                  type = types.str;
                  default = "YYYY-MM-DD";
                };
              };
            };
          in {
            console = mkOption {
              type = with types; coercedTo loggingLevelType (level: { inherit level; }) (submodule loggingInterfaceConfig);
              default = { };
            };
            lineDateFormat = mkOption {
              type = types.str;
              default = "MMM-D HH:mm:ss.SSS";
              description = "moment.js format";
            };
            files = mkOption {
              type = with types; listOf (submodule loggingFileConfig);
              default = [ ];
            };
          };
          database = {
            connString = mkOption {
              type = with types; nullOr str;
              default = null;
            };
            filename = mkOption {
              type = with types; nullOr str;
              default = "database.db";
            };
          };
          metrics = {
            enabled = mkOption {
              type = types.bool;
              default = false;
            };
            port = mkOption {
              type = types.port;
              default = 8000;
            };
            path = mkOption {
              type = types.str;
              default = "/metrics";
            };
          };
          provisioning = {
            whitelist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
            blacklist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
            sharedSecret = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            apiPrefix = mkOption {
              type = with types; nullOr str;
              default = null;
              #default = "/_matrix/provision";
            };
          };
          relay = {
            whitelist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
            blacklist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
          };
          selfService = {
            whitelist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
            blacklist = mkOption {
              type = with types; listOf str;
              default = [ ];
            };
          };
          homeserverUrlMap = mkOption {
            type = with types; attrsOf str;
            default = { };
          };
          namePatterns = {
            user = mkOption {
              type = types.str;
              default = ":name";
            };
            userOverride = mkOption {
              type = types.str;
              default = ":name";
            };
            room = mkOption {
              type = types.str;
              default = ":name";
            };
            group = mkOption {
              type = types.str;
              default = ":name";
            };
            emote = mkOption {
              type = types.str;
              default = ":name";
            };
          };
          limits = {
            maxAutojoinUsers = mkOption {
              type = types.int;
              default = 200;
            };
            roomUserAutojoinDelay = mkOption {
              type = types.int;
              default = 5000;
            };
          };
        };
        config = {
          provisioning.whitelist = mkIf matrix-synapse.enable (mkDefault [
            "@.*:${escapeRegex matrix-synapse.settings.server_name}"
          ]);
          bridge = mkIf matrix-synapse.enable {
            homeserverUrl = mkOptionDefault matrix-synapse.settings.public_baseurl;
            domain = mkOptionDefault matrix-synapse.settings.server_name;
          };
          registration = {
            host = mkDefaultOverride config.bridge.bindAddress;
            port = mkDefaultOverride config.bridge.port;
            senderLocalpart = mkDefaultOverride "${config.registrationPrefix}bot";
            pushEphemeral = mkDefaultOverride true;
            namespaces = {
              aliases = mkDefault [ {
                regex = "#${config.registrationPrefix}.*";
              } ];
              users = mkDefault [ {
                regex = "@${config.registrationPrefix}.*";
              } ];
            };
          };
          configuration.settings = {
            bridge = {
              inherit (config.bridge) port bindAddress domain homeserverUrl displayname enableGroupSync stripHomeservers;
              mediaUrl = mkIf (config.bridge.mediaUrl != null) config.bridge.mediaUrl;
              avatarUrl = mkIf (config.bridge.avatarUrl != null) config.bridge.avatarUrl;
            };
            provisioning = {
              inherit (config.provisioning) whitelist blacklist;
              sharedSecret = mkIf (config.provisioning.sharedSecret != null) config.provisioning.sharedSecret;
              apiPrefix = mkIf (config.provisioning.apiPrefix != null) config.provisioning.apiPrefix;
            };
            relay = {
              inherit (config.relay) whitelist blacklist;
            };
            selfService = {
              inherit (config.relay) whitelist blacklist;
            };
            homeserverUrlMap = mkIf (config.homeserverUrlMap != { }) config.homeserverUrlMap;
            namePatterns = {
              inherit (config.namePatterns) user userOverride room group emote;
            };
            database = {
              connString = mkIf (config.database.connString != null) config.database.connString;
              filename = mkIf (config.database.filename != null) config.database.filename;
            };
            limits = {
              inherit (config.limits) maxAutojoinUsers roomUserAutojoinDelay;
            };
            logging = {
              inherit (config.logging) console lineDateFormat files;
            };
          };
          configuration.sensitiveSettings = mkIf (config.bridge.loginSharedSecretMap != { }) {
            bridge = mkIf (config.bridge.loginSharedSecretMap != { }) {
              inherit (config.bridge) loginSharedSecretMap;
            };
          };
          cmdargs = [
            "-f" config.registration.configuration.path
          ];
        };
      };
    };
  };
}
