{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    types
    getExe
    ;

  inherit (types)
    submodule
    attrs
    path
    nullOr
    bool
    str
    ints
    listOf
    numbers
    enum
    ;

  cfg = config.services.git-pages;

  configFormat = pkgs.formats.toml { };
in
{
  options.services.git-pages = {
    enable = mkEnableOption "git-pages, Scalable static site server for Git forges (like GitHub Pages or Netlify)";
    package = mkPackageOption pkgs "git-pages" { };
    configFile = mkOption {
      description = "file that contains the server config, overrides services.git-pages.settings!";
      type = path;
      default = configFormat.generate "git-pages.toml" cfg.settings;
      defaultText = "<<generated TOML from services.git-pages.settings>>";
    };
    enableWrapper = mkOption {
      description = "Whether to add a wrapped git-pages to the path that refers to the server's config file";
      type = bool;
      default = true;
      example = false;
    };
    environmentFile = mkOption {
      description = ''
        File that contains values for the git-pages config. This file may be used for secrets.

        ::: {.note}
        See the [git-pages documentation](https://git-pages.org/running-a-server/#environment-variables) on environment variables.
        :::
      '';
      type = nullOr path;
      default = null;
      example = "/run/secrets/git-pages.env";
    };
    settings = mkOption {
      description = "git-pages server config";
      type = submodule {
        freeformType = attrs;
        options = {
          audit = {
            collect = mkEnableOption "collecting audit logs";
            include-ip = mkOption {
              type = str;
              default = "";
              description = "IP addresses or CIDR blocks to include in auditing";
            };
            node-id = mkOption {
              type = ints.unsigned;
              default = 0;
              description = "Unique ID for the cluster node producing the audit logs";
            };
            notify-url = mkOption {
              type = str;
              default = "";
              description = "Webhook URL to notify when audit events are triggered";
            };
          };
          fallback = {
            insecure = mkEnableOption "allowing insecure fallback connections (e.g., ignoring untrusted SSL certificates)";
            proxy-to = mkOption {
              type = str;
              default = "https://codeberg.page";
              description = "The upstream target URL to proxy requests to when a matching page is not found";
            };
          };
          limits = {
            allow-basic-auth = mkOption {
              type = bool;
              default = false;
              description = "Whether HTTP Basic Authentication is allowed for hosted sites";
            };
            allow-expiration = mkOption {
              type = bool;
              default = false;
              description = "Allow deployment expirations or TTLs on hosted sites";
            };
            allowed-custom-headers = mkOption {
              type = listOf str;
              default = [ "X-Clacks-Overhead" ];
              description = "HTTP response headers that sites are allowed to customize";
            };
            allowed-repository-url-prefixes = mkOption {
              type = listOf str;
              default = [ ];
              description = "Allowed Git repository URL prefixes for deployment origins";
            };
            concurrent-uploads = mkOption {
              type = ints.positive;
              default = 1024;
              description = "Maximum number of simultaneous file uploads allowed globally";
            };
            forbidden-domains = mkOption {
              type = listOf str;
              default = [ ];
              description = "List of domain names or patterns forbidden from being used as custom domains";
            };
            git-large-object-threshold = mkOption {
              type = str;
              default = "1M";
              description = "The file size threshold after which objects are handled as Git Large Files";
            };
            max-heap-size-ratio = mkOption {
              type = numbers.between 0.0 1.0;
              default = 0.5;
              description = "The fraction of system memory the server process runtime is allowed to utilize";
            };
            max-inline-file-size = mkOption {
              type = str;
              default = "256B";
              description = "Maximum size of files that can be stored inline in metadata structures rather than written to disk storage";
            };
            max-manifest-size = mkOption {
              type = str;
              default = "1M";
              description = "Maximum allowed size of a site deployment manifest file";
            };
            max-site-size = mkOption {
              type = str;
              default = "128M";
              description = "Maximum total uncompressed size limit for a single deployed static site";
            };
            max-symlink-depth = mkOption {
              type = ints.unsigned;
              default = 16;
              description = "Maximum depth of symbolic link resolution before throwing a traversal error";
            };
            update-timeout = mkOption {
              type = str;
              default = "60s";
              description = "Maximum duration permitted for an update or site build operation to finish";
            };
          };
          log-format = mkOption {
            type = enum [
              "text"
              "json"
            ];
            default = "text";
            description = "The formatting layout for system logging";
          };
          observability.slow-response-threshold = mkOption {
            type = str;
            default = "500ms";
            description = "Requests taking longer than this duration will be logged as slow responses";
          };
          server = {
            caddy = mkOption {
              type = str;
              default = "-";
              description = "Configuration path or control address for Caddy integration. Set to '-' to disable";
            };
            metrics = mkOption {
              type = str;
              default = "-";
              description = "Network address or path to expose Prometheus metrics. Set to '-' to disable";
            };
            pages = mkOption {
              type = str;
              default = "tcp/localhost:3000";
              description = "Network address socket bind point for serving static site pages";
            };
          };
          storage.fs.root = mkOption {
            type = str;
            default = "./data";
            description = "The path on the local filesystem serving as root storage directory for deployments";
          };
        };
      };
      default = { };
    };
  };
  config = mkIf cfg.enable {
    services.git-pages.settings = {
      audit = {
        collect = mkDefault false;
        include-ip = mkDefault "";
        node-id = mkDefault 0;
        notify-url = mkDefault "";
      };
      fallback = {
        insecure = mkDefault false;
        proxy-to = mkDefault "https://codeberg.page";
      };
      limits = {
        allow-basic-auth = mkDefault false;
        allow-expiration = mkDefault false;
        allowed-custom-headers = mkDefault [ "X-Clacks-Overhead" ];
        allowed-repository-url-prefixes = mkDefault [ ];
        concurrent-uploads = mkDefault 1024;
        forbidden-domains = mkDefault [ ];
        git-large-object-threshold = mkDefault "1M";
        max-heap-size-ratio = mkDefault 0.5;
        max-inline-file-size = mkDefault "256B";
        max-manifest-size = mkDefault "1M";
        max-site-size = mkDefault "128M";
        max-symlink-depth = mkDefault 16;
        update-timeout = mkDefault "60s";
      };
      log-format = mkDefault "text";
      observability.slow-response-threshold = mkDefault "500ms";
      server = {
        caddy = mkDefault "-";
        metrics = mkDefault "-";
        pages = mkDefault "tcp/localhost:3000";
      };
      storage.fs.root = mkDefault "/var/lib/private/git-pages/data";
    };

    systemd.services.git-pages = {
      description = "git-pages, Scalable static site server for Git forges (like GitHub Pages or Netlify)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.settings.storage.fs.root}/blob
      '';
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${getExe cfg.package} -config ${cfg.configFile}
        '';
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = "git-pages";
        WorkingDirectory = "%S/git-pages";
        Restart = "on-failure";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };

    environment.systemPackages = mkIf cfg.enableWrapper [
      (pkgs.writeShellApplication {
        name = "git-pages";
        runtimeInputs = [ cfg.package ];
        text = ''
          git-pages -config ${cfg.configFile} "$@"
        '';
      })
    ];
  };
}
