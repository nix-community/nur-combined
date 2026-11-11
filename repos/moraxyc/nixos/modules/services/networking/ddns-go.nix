{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.ddns-go;
  settingsFormat = pkgs.formats.yaml { };

  noConfigFile = cfg.configFile == null;
  bindPrivileged = cfg.port < 1024;

  # systemd cannot parse hostnames in ListenStream, so map the default host.
  socketHost = if cfg.host == "localhost" then "127.0.0.1" else cfg.host;
  tcpListenStream = "${
    if lib.hasInfix ":" socketHost then "[${socketHost}]" else socketHost
  }:${toString cfg.port}";
  useSocket = cfg.socketActivation || cfg.unixSocket != null;

  # Generate merged ddns-go config with secrets.
  gen-ddns-go-config = pkgs.writeShellApplication {
    name = "gen-ddns-go-config";
    runtimeInputs = with pkgs; [ yq-go ];
    text =
      utils.genJqSecretsReplacementSnippet cfg.settings "/run/ddns-go/new"
      # Merge existing config with new settings, overriding existing values with new ones
      + lib.optionalString cfg.mutableConfig ''
        if [ -f /etc/ddns-go/config.yaml ]; then

        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
        /etc/ddns-go/config.yaml /run/ddns-go/new > /run/ddns-go/tmp

        [ -f /run/ddns-go/tmp ] && mv /run/ddns-go/tmp /run/ddns-go/new

        fi
      ''
      # Finalize the configuration update by replacing the existing config file.
      + ''
        mv /run/ddns-go/new /etc/ddns-go/config.yaml
        chown --reference=/etc/ddns-go /etc/ddns-go/config.yaml
      '';
  };
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.ddns-go = {
      enable = lib.mkEnableOption "Simple and easy to use DDNS";

      package = lib.mkPackageOption pkgs "ddns-go" { };

      mutableConfig = lib.mkOption {
        type = lib.types.bool;
        # The web interface is the primary configuration method recommended by the upstream.
        default = true;
        description = "Allow ddns-go to persist settings in the config file.";
      };

      configFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to ddns-go config file.
          Setting this option will override any configuration applied by the settings option.
        '';
      };

      extraFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "-noweb" ];
        description = ''
          Extra flags passed to the ddns-go command.
        '';
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = ''
          Address for the web server to listen on.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 9876;
        description = ''
          Port for the web server to listen on.
        '';
      };

      socketActivation = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to use systemd socket activation for the web interface.

          systemd binds {option}`services.ddns-go.host` and {option}`services.ddns-go.port`
          and passes the socket to ddns-go. This requires the patched ddns-go package
          from this repository; the upstream package will fail to bind the port.
          The service still starts at boot, since DDNS updates do not depend on HTTP requests.
        '';
      };

      unixSocket = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        example = "/run/ddns-go/ddns-go.sock";
        description = ''
          Unix socket on which the ddns-go web interface listens, instead of
          {option}`services.ddns-go.host` and {option}`services.ddns-go.port`.
          Implies {option}`services.ddns-go.socketActivation`. systemd creates the
          socket with mode `0660`; when {option}`services.ddns-go.configureNginx`
          is enabled its group is set to nginx's group. Override
          `systemd.sockets.ddns-go.socketConfig` to change the permissions.
        '';
      };

      configureNginx = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to configure nginx as a reverse proxy for ddns-go.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        example = "ddns.example.org";
        description = "Domain name for the nginx virtual host.";
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        description = ''
          The ddns-go configuration, see <https://github.com/jeessy2/ddns-go#readme>
          for possible options.

          Options containing secret data should be set as an attribute set
          with the `_secret` attribute. This should be a string or a structured
          JSON with `quote = false;`, pointing to a file that contains the value.

          Note: This option is ignored if `configFile` is set.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.configFile != null -> cfg.settings == { };
        message = "When services.ddns-go.configFile is set, settings must be empty.";
      }
    ];

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass =
            if cfg.unixSocket != null then
              "http://unix:${cfg.unixSocket}:/"
            else
              "http://${socketHost}:${toString cfg.port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    systemd.sockets.ddns-go = lib.mkIf useSocket {
      description = "ddns-go socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ (if cfg.unixSocket != null then cfg.unixSocket else tcpListenStream) ];
      socketConfig =
        if cfg.unixSocket != null then
          {
            SocketMode = lib.mkDefault "0660";
            SocketGroup = lib.mkIf cfg.configureNginx (lib.mkDefault config.services.nginx.group);
          }
        else
          {
            # Socket units start before network-online.target, so the address may not exist yet.
            FreeBind = true;
          };
    };

    systemd.services.ddns-go = {
      description = "ddns-go dynamic DNS service";
      after = [ "network.target" ] ++ lib.optional useSocket "ddns-go.socket";
      requires = lib.optional useSocket "ddns-go.socket";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        # Pre-start hook to generate the config file if configFile is not set.
        # genJqSecretsReplacementSnippet may need to access files outside ReadWritePaths.
        ExecStartPre = lib.optional noConfigFile "+${lib.getExe gen-ddns-go-config}";
        ExecStart =
          "${lib.getExe cfg.package} "
          + lib.escapeShellArgs (
            [
              "-c"
              (if noConfigFile then "/etc/ddns-go/config.yaml" else cfg.configFile)
              "-l"
              "${cfg.host}:${toString cfg.port}"
            ]
            ++ cfg.extraFlags
          );
        Type = "simple";
        Restart = "on-failure";
        RuntimeDirectory = "ddns-go";
        # RuntimeDirectoryMode = "0600";
        ConfigurationDirectory = "ddns-go";
        # ConfigurationDirectoryMode = "0600";

        # Hardening
        ReadWritePaths = [ "/etc/ddns-go" ] ++ lib.optional (!noConfigFile) cfg.configFile;
        # Since configFile permissions cannot be adjusted automatically.
        DynamicUser = noConfigFile;
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        # Must disable PrivateUsers when binding to privileged ports (<1024)
        PrivateUsers = !bindPrivileged;
        AmbientCapabilities = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        CapabilityBoundingSet = if bindPrivileged then "CAP_NET_BIND_SERVICE" else "";
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];
      };
    };
  };
}
