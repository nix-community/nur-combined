{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;

  cfg = config.services.futu-opend-rs;

  tomlFormat = pkgs.formats.toml { };

  # Attach a scalar TOML key only when its value is non-null.
  optional = name: value: optionalAttrs (value != null) { ${name} = value; };

  # Same as `optional`, but for `types.path` values that must be coerced to a
  # plain string before the TOML generator sees them.
  optionalPath = name: value: optionalAttrs (value != null) { ${name} = toString value; };

  # Attach a boolean TOML key only when explicitly enabled. `false` is the
  # daemon default, so omitting the key is equivalent and keeps the config lean.
  optionalFlag = name: enabled: optionalAttrs enabled { ${name} = true; };

  # ---------------------------------------------------------------------------
  # Gateway (futu-opend)
  # ---------------------------------------------------------------------------

  hasSopsSecrets = cfg.sops.loginAccount != null || cfg.sops.loginPwd != null;

  loginAccount =
    if cfg.sops.loginAccount != null then
      config.sops.placeholder.${cfg.sops.loginAccount}
    else
      cfg.loginAccount;

  loginPwd =
    if cfg.sops.loginPwd != null then config.sops.placeholder.${cfg.sops.loginPwd} else cfg.loginPwd;

  gatewayToml = {
    ip = cfg.ip;
    port = cfg.port;
    platform = cfg.platform;
    lang = cfg.lang;
    log_level = cfg.logLevel;
  }
  // optional "login_account" loginAccount
  // optional "login_pwd" loginPwd
  // optionalPath "login_pwd_file" cfg.loginPwdFile
  // optional "login_region" cfg.loginRegion
  // optional "rest_port" cfg.rest.port
  // optional "grpc_port" cfg.grpc.port
  // optional "websocket_port" cfg.websocket.port
  // optional "telnet_ip" cfg.telnet.ip
  // optional "telnet_port" cfg.telnet.port
  // optional "rsa_private_key" cfg.rsaPrivateKey
  // optionalPath "rest_keys_file" cfg.rest.keysFile
  // optional "rest_tls_cert" cfg.rest.tlsCert
  // optional "rest_tls_key" cfg.rest.tlsKey
  // optionalPath "grpc_keys_file" cfg.grpc.keysFile
  // optionalPath "ws_keys_file" cfg.websocket.keysFile
  // optionalFlag "allow_tcp_unauthenticated" cfg.allowTcpUnauthenticated
  // optional "audit_log" cfg.auditLog
  // optional "tz" cfg.tz
  // optionalFlag "client_sig_proactive_refresh" cfg.clientSigProactiveRefresh
  // optionalFlag "client_sig_reactive_refresh" cfg.clientSigReactiveRefresh;

  configFile = tomlFormat.generate "futu-opend.toml" gatewayToml;
  configPath =
    if hasSopsSecrets then "/run/credentials/futu-opend-rs.service/futu-opend.toml" else configFile;

  gatewayExecStart = [
    (lib.getExe' cfg.package "futu-opend")
    "--config"
    configPath
  ]
  ++ lib.optional cfg.jsonLog "--json-log"
  ++ cfg.extraArgs;

  # ---------------------------------------------------------------------------
  # MCP server (futu-mcp)
  # ---------------------------------------------------------------------------

  mcpToml = {
    gateway = cfg.mcp.gateway;
    http_listen = cfg.mcp.httpListen;
  }
  // optionalPath "keys_file" cfg.mcp.keysFile
  // optional "tls_cert" cfg.mcp.tlsCert
  // optional "tls_key" cfg.mcp.tlsKey
  // optional "audit_log" cfg.mcp.auditLog;

  mcpConfigFile = tomlFormat.generate "futu-mcp.toml" mcpToml;

  mcpExecStart = [
    (lib.getExe' cfg.package "futu-mcp")
    "--config"
    mcpConfigFile
  ]
  ++ cfg.mcp.extraArgs;

in
{
  options.services.futu-opend-rs = {
    enable = mkEnableOption "the FutuOpenD-rs gateway (the unofficial Rust reimplementation of Futu OpenD)";

    package = mkOption {
      type = types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system (
        { config, ... }: config.packages.futu-opend-rs
      );
      defaultText = lib.literalMD "`packages.futu-opend-rs` from the shirok1/flakes flake";
      description = "The futu-opend-rs package to use.";
    };

    loginAccount = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Futu login account (user ID, phone number, or email). Use `sops.loginAccount` instead to keep it out of the Nix store.";
      example = "100000";
    };

    loginPwd = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Plain-text Futu login password. Use `sops.loginPwd` or `loginPwdFile` instead to keep it out of the Nix store.";
    };

    loginPwdFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing the login password. This maps to the daemon's
        preferred `login_pwd_file` option, keeping the password out of argv.

        The file must be readable by the service user (for example a path
        copied into the Nix store, or a file made available through another
        mechanism).
      '';
    };

    loginRegion = mkOption {
      type = types.nullOr (
        types.enum [
          "gz"
          "sh"
          "hk"
        ]
      );
      default = null;
      description = "Futunn backend data-centre region. Only applies to `futunn` platform accounts. Null uses the daemon default (`gz`).";
    };

    platform = mkOption {
      type = types.enum [
        "futunn"
        "moomoo"
      ];
      default = "futunn";
      description = "Account platform: `futunn` (Futubull, CN/HK) or `moomoo` (US/SG/AU/JP/CA).";
    };

    sops = {
      loginAccount = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Name of a sops-nix secret to inject as `login_account`.";
        example = "futu-opend-rs/login-account";
      };

      loginPwd = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Name of a sops-nix secret to inject as `login_pwd`.";
        example = "futu-opend-rs/login-pwd";
      };
    };

    ip = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Gateway listen address (FTAPI TCP plus the REST/gRPC/WS ports that have no separate bind address). Set to `0.0.0.0` to expose the gateway to remote SDK clients.";
    };

    port = mkOption {
      type = types.port;
      default = 11111;
      description = "FTAPI TCP port — the native protocol used by the Python/C++ SDK.";
    };

    rest = {
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "REST API port (also serves `/ws`). Null disables REST.";
        example = 22222;
      };

      keysFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "keys.json for REST Bearer Token auth. Enabling it switches REST into scope mode and requires `tlsCert` and `tlsKey`.";
      };

      tlsCert = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "REST TLS certificate chain (PEM).";
      };

      tlsKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "REST TLS private key (PEM).";
      };
    };

    grpc = {
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "gRPC port. Null disables gRPC.";
        example = 33333;
      };

      keysFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "keys.json for gRPC Bearer Token auth.";
      };
    };

    websocket = {
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Core WebSocket port (used by the Futu SDK). Null disables WebSocket.";
      };

      keysFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "keys.json for WebSocket handshake/message auth.";
      };
    };

    telnet = {
      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Telnet admin listen address. Only used when `port` is set.";
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Telnet admin port. Null disables Telnet.";
      };
    };

    rsaPrivateKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "RSA private-key file path (PEM) for API protocol encryption. Null uses the built-in default key.";
    };

    allowTcpUnauthenticated = mkOption {
      type = types.bool;
      default = false;
      description = "Explicitly keep the native FTAPI TCP port open when any keys file is configured. By default the daemon closes the TCP port (fail-closed) once auth is enabled.";
    };

    lang = mkOption {
      type = types.enum [
        "chs"
        "cht"
        "en"
      ];
      default = "chs";
      description = "UI language.";
    };

    logLevel = mkOption {
      type = types.enum [
        "trace"
        "debug"
        "info"
        "warn"
        "error"
        "off"
      ];
      default = "info";
      description = "Log level.";
    };

    jsonLog = mkOption {
      type = types.bool;
      default = false;
      description = "Emit structured JSON logs on stdout.";
    };

    auditLog = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Audit JSONL file or directory. Null disables the separate audit log.";
      example = "/var/log/futu-opend-rs/";
    };

    tz = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "IANA timezone override (e.g. `Asia/Hong_Kong`) used for `hours_window` limit checks.";
    };

    clientSigProactiveRefresh = mkOption {
      type = types.bool;
      default = false;
      description = "Proactively refresh `client_sig` one hour before expiry (long-running daemon hardening, experimental).";
    };

    clientSigReactiveRefresh = mkOption {
      type = types.bool;
      default = false;
      description = "Refresh `client_sig` after repeated TCP login failures (long-running daemon hardening, experimental).";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra CLI arguments appended to the gateway invocation, for CLI-only flags such as `--setup-only` or `--device-id`.";
      example = [ "--setup-only" ];
    };

    mcp = {
      enable = mkEnableOption "the FutuOpenD-rs MCP server (HTTP transport)";

      gateway = mkOption {
        type = types.str;
        default = "127.0.0.1:11111";
        description = "Gateway address the MCP server connects to.";
      };

      httpListen = mkOption {
        type = types.str;
        default = "127.0.0.1:38765";
        description = "HTTP transport listen address (`host:port` or `:port`).";
      };

      keysFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "keys.json for MCP scope mode.";
      };

      tlsCert = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "TLS certificate chain (PEM). Requires `tlsKey`.";
      };

      tlsKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "TLS private key (PEM). Requires `tlsCert`.";
      };

      auditLog = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Audit JSONL file or directory for the MCP server.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra CLI arguments appended to the MCP invocation.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.loginAccount == null) != (cfg.sops.loginAccount == null);
        message = "Exactly one of services.futu-opend-rs.loginAccount or services.futu-opend-rs.sops.loginAccount must be set.";
      }
      {
        assertion =
          builtins.length (
            builtins.filter (value: value != null) [
              cfg.loginPwd
              cfg.loginPwdFile
              cfg.sops.loginPwd
            ]
          ) == 1;
        message = "Exactly one of services.futu-opend-rs.loginPwd, loginPwdFile, or sops.loginPwd must be set.";
      }
      {
        assertion = cfg.rest.keysFile == null || (cfg.rest.tlsCert != null && cfg.rest.tlsKey != null);
        message = "services.futu-opend-rs.rest.keysFile requires both rest.tlsCert and rest.tlsKey to be set.";
      }
      {
        assertion = (cfg.mcp.tlsCert == null) == (cfg.mcp.tlsKey == null);
        message = "services.futu-opend-rs.mcp.tlsCert and mcp.tlsKey must be set together.";
      }
    ];

    sops.templates = mkIf hasSopsSecrets {
      "futu-opend.toml".content = builtins.readFile configFile;
    };

    systemd.services.futu-opend-rs = {
      description = "FutuOpenD-rs Gateway (TCP/REST/gRPC/WS)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      restartIfChanged = true;

      serviceConfig = rec {
        ExecStart = lib.concatStringsSep " " gatewayExecStart;
        LoadCredential = mkIf hasSopsSecrets [
          "futu-opend.toml:${config.sops.templates."futu-opend.toml".path}"
        ];
        Restart = "on-failure";
        RestartSec = "5s";

        DynamicUser = true;
        StateDirectory = "futu-opend-rs";
        WorkingDirectory = "/var/lib/${StateDirectory}";
        # The daemon persists its device-id and backend session cache under
        # ~/.futu-opend-rs/ and ~/.config/futu/; point HOME at the writable
        # state directory so those survive restarts.
        Environment = "HOME=/var/lib/${StateDirectory}";

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        LimitNOFILE = 65535;
      };
    };

    systemd.services.futu-opend-rs-mcp = mkIf cfg.mcp.enable {
      description = "FutuOpenD-rs MCP server (HTTP transport)";
      wantedBy = [ "multi-user.target" ];
      after = [
        "futu-opend-rs.service"
        "network-online.target"
      ];
      wants = [
        "futu-opend-rs.service"
        "network-online.target"
      ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " mcpExecStart;
        Restart = "on-failure";
        RestartSec = "5s";

        DynamicUser = true;
        StateDirectory = "futu-opend-rs-mcp";
        WorkingDirectory = "/var/lib/futu-opend-rs-mcp";

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        RestrictSUIDSGID = true;
        LimitNOFILE = 65535;
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
