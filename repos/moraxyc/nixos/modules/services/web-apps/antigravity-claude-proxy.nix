{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.antigravity-claude-proxy;
  format = pkgs.formats.json { };
  configFile = format.generate "antigravity-claude-proxy.json" cfg.settings;

  stateDir = "/var/lib/antigravity-claude-proxy";
  # The upstream service derives every other path from `$HOME`.
  dataDir = "${stateDir}/.config/antigravity-proxy";

  proxyHost =
    if cfg.listenAddress == "0.0.0.0" then
      "127.0.0.1"
    else if cfg.listenAddress == "::" then
      "::1"
    else
      cfg.listenAddress;
  proxyPass = "http://${
    if lib.hasInfix ":" proxyHost then "[${proxyHost}]" else proxyHost
  }:${toString cfg.port}";

  serverArgs =
    lib.optional (cfg.strategy != null) "--strategy=${cfg.strategy}"
    ++ lib.optional cfg.modelFallback "--fallback"
    ++ cfg.extraArgs;
in
{
  options.services.antigravity-claude-proxy = {
    enable = lib.mkEnableOption "Antigravity Claude Proxy, an Anthropic-compatible API in front of Antigravity's Cloud Code";

    package = lib.mkPackageOption pkgs "antigravity-claude-proxy" { };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = ''
        Address on which the proxy listens.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = ''
        TCP port on which the proxy listens. The dashboard, the `/v1` API, and
        the OAuth callback use it.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open {option}`services.antigravity-claude-proxy.port` in the
        firewall.
      '';
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to configure nginx as a reverse proxy for the proxy.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "antigravity.example.org";
      description = ''
        Domain name for the nginx virtual host.
      '';
    };

    settings = lib.mkOption {
      type = format.type;
      default = { };
      example = {
        logLevel = "debug";
        maxAccounts = 3;
        accountSelection.strategy = "round-robin";
      };
      description = ''
        Configuration written to `${dataDir}/config.json`, overriding the
        built-in defaults; see `config.example.json` upstream for the accepted
        keys.

        The file is rewritten on every start, so changes made through the
        dashboard's settings page do not survive a restart. Manage accounts
        through the dashboard instead: they are stored in
        `${dataDir}/accounts.json`, which this module does not manage.

        Secrets belong in {option}`services.antigravity-claude-proxy.environmentFile`,
        {option}`services.antigravity-claude-proxy.apiKeyFile`, or
        {option}`services.antigravity-claude-proxy.webuiPasswordFile` rather than
        here, because this file is world-readable in the Nix store.
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/antigravity-claude-proxy.env";
      description = ''
        Environment file read by systemd, for settings without a dedicated
        option and for secrets such as `HTTP_PROXY`. Variables set here
        override {option}`services.antigravity-claude-proxy.settings`.
      '';
    };

    apiKeyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/antigravity-claude-proxy-api-key";
      description = ''
        File containing the API key that clients must send to `/v1` endpoints,
        loaded via systemd `LoadCredential` and exported as `API_KEY`.
      '';
    };

    webuiPasswordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/antigravity-claude-proxy-webui-password";
      description = ''
        File containing the dashboard password, loaded via systemd
        `LoadCredential` and exported as `WEBUI_PASSWORD`. When set,
        `/health`, `/account-limits`, and the dashboard API require the
        `X-WebUI-Password` header.
      '';
    };

    oauthCallbackPort = lib.mkOption {
      type = lib.types.port;
      default = 51121;
      description = ''
        Port of the local callback server that completes the Google OAuth flow
        when an account is added, exported as `OAUTH_CALLBACK_PORT`.
      '';
    };

    claudeConfigPath = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/home/alice/.claude";
      description = ''
        The `.claude` directory that the dashboard's Claude Code integration
        reads and writes, exported as `CLAUDE_CONFIG_PATH`. The service user's
        home is `${stateDir}`, so set this to edit another user's Claude Code
        settings; it also turns off `ProtectHome`.
      '';
    };

    strategy = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "sticky"
          "round-robin"
          "hybrid"
        ]);
      default = null;
      example = "sticky";
      description = ''
        Account selection strategy, as the `--strategy` flag. When `null`, the
        value of `accountSelection.strategy` in
        {option}`services.antigravity-claude-proxy.settings` applies.
      '';
    };

    modelFallback = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to fall back to another model when the requested one is out of
        quota, as the `--fallback` flag.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--dev-mode" ];
      description = ''
        Extra arguments passed to the server entry point.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          inherit proxyPass;
          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 64m;
            proxy_buffering off;
            proxy_read_timeout 600s;
          '';
        };
      };
    };

    systemd.services.antigravity-claude-proxy = {
      description = "Antigravity Claude Proxy";
      documentation = [ "https://github.com/badrisnarayanan/antigravity-claude-proxy" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        HOME = stateDir;
        HOST = cfg.listenAddress;
        PORT = toString cfg.port;
        OAUTH_CALLBACK_PORT = toString cfg.oauthCallbackPort;
      }
      // lib.optionalAttrs (cfg.claudeConfigPath != null) {
        CLAUDE_CONFIG_PATH = cfg.claudeConfigPath;
      };

      path = [ pkgs.coreutils ];

      preStart = lib.optionalString (cfg.settings != { }) ''
        install -d -m 0700 ${dataDir}
        install -m 0600 ${configFile} ${dataDir}/config.json
      '';

      script = ''
        if [ -n "''${CREDENTIALS_DIRECTORY:-}" ]; then
          for credential in api-key webui-password; do
            if [ -r "$CREDENTIALS_DIRECTORY/$credential" ]; then
              value="$(cat "$CREDENTIALS_DIRECTORY/$credential")"
              case "$credential" in
                api-key) export API_KEY="$value" ;;
                webui-password) export WEBUI_PASSWORD="$value" ;;
              esac
            fi
          done
        fi

        exec ${lib.getExe' cfg.package "antigravity-claude-proxy-server"} ${lib.escapeShellArgs serverArgs}
      '';

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        LoadCredential =
          lib.optionals (cfg.apiKeyFile != null) [ "api-key:${cfg.apiKeyFile}" ]
          ++ lib.optionals (cfg.webuiPasswordFile != null) [
            "webui-password:${cfg.webuiPasswordFile}"
          ];

        DynamicUser = true;
        User = "antigravity-claude-proxy";
        Group = "antigravity-claude-proxy";

        WorkingDirectory = stateDir;
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "antigravity-claude-proxy";
        StateDirectoryMode = "0750";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # Required by V8 JIT
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = cfg.claudeConfigPath == null;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
