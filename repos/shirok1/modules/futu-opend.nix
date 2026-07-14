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

  cfg = config.services.futu-opend;

  xmlFormat = pkgs.formats.xml { };

  optionalTextTag = name: value: optionalAttrs (value != null) { ${name}."#text" = value; };
  optionalIntTag = name: value: optionalAttrs (value != null) { ${name}."#text" = toString value; };

  hasSopsSecrets =
    cfg.sops.loginAccount != null || cfg.sops.loginPwd != null || cfg.sops.loginPwdMd5 != null;

  loginAccount =
    if cfg.sops.loginAccount != null then
      config.sops.placeholder.${cfg.sops.loginAccount}
    else
      cfg.loginAccount;

  loginPwdMd5 =
    if cfg.sops.loginPwdMd5 != null then
      config.sops.placeholder.${cfg.sops.loginPwdMd5}
    else
      cfg.loginPwdMd5;

  loginPwd =
    if cfg.sops.loginPwd != null then config.sops.placeholder.${cfg.sops.loginPwd} else cfg.loginPwd;

  badgerfish = {
    futu_opend = {
      ip."#text" = cfg.ip;
      api_port."#text" = toString cfg.apiPort;
      login_account."#text" = loginAccount;
      lang."#text" = cfg.lang;
      log_level."#text" = cfg.logLevel;
      push_proto_type."#text" = toString cfg.pushProtoType;
      price_reminder_push."#text" = if cfg.priceReminderPush then "1" else "0";
      auto_hold_quote_right."#text" = if cfg.autoHoldQuoteRight then "1" else "0";
      future_trade_api_time_zone."#text" = cfg.futureTradeApiTimeZone;
      pdt_protection."#text" = if cfg.pdtProtection then "1" else "0";
      dtcall_confirmation."#text" = if cfg.dtcallConfirmation then "1" else "0";
    }
    // optionalTextTag "login_pwd_md5" loginPwdMd5
    // optionalTextTag "login_pwd" loginPwd
    // optionalTextTag "log_path" cfg.logPath
    // optionalIntTag "qot_push_frequency" cfg.qotPushFrequency
    // optionalTextTag "telnet_ip" cfg.telnet.ip
    // optionalIntTag "telnet_port" cfg.telnet.port
    // optionalTextTag "rsa_private_key" cfg.rsaPrivateKey
    // optionalTextTag "websocket_ip" cfg.websocket.ip
    // optionalIntTag "websocket_port" cfg.websocket.port
    // optionalTextTag "websocket_key_md5" cfg.websocket.keyMd5
    // optionalTextTag "websocket_private_key" cfg.websocket.privateKey
    // optionalTextTag "websocket_cert" cfg.websocket.cert;
  };

  configFile = xmlFormat.generate "FutuOpenD.xml" badgerfish;
  configPath =
    if hasSopsSecrets then "/run/credentials/futu-opend.service/FutuOpenD.xml" else configFile;

in
{
  options.services.futu-opend = {
    enable = mkEnableOption "FutuOpenD gateway service.";

    package = mkOption {
      type = types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.futu-opend);
      defaultText = lib.literalMD "`packages.futu-opend` from the shirok1/flakes flake";
      description = "The FutuOpenD package to use.";
    };

    ip = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "API protocol listening address.";
    };

    apiPort = mkOption {
      type = types.port;
      default = 11111;
      description = "API interface protocol listening port.";
    };

    loginAccount = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Login account: user ID, phone number, or email. Use sops.loginAccount instead to avoid storing it in the Nix store.";
      example = "100000";
    };

    loginPwdMd5 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Login password as 32-character MD5 hex. Use sops.loginPwdMd5 instead to avoid storing it in the Nix store.";
      example = "6e55f158a827b1a1c4321a245aaaad88";
    };

    loginPwd = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Plain-text login password. Use sops.loginPwd instead to avoid storing it in the Nix store.";
      example = "123456";
    };

    sops = {
      loginAccount = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of a sops-nix secret to inject as login_account via
          `sops.templates`.

          The secret must be defined separately in `sops.secrets`.
        '';
        example = "futu-opend/login-account";
      };

      loginPwdMd5 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of a sops-nix secret to inject as login_pwd_md5 via
          `sops.templates`.

          The secret must be defined separately in `sops.secrets`.
        '';
        example = "futu-opend/login-pwd-md5";
      };

      loginPwd = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of a sops-nix secret to inject as login_pwd via
          `sops.templates`.

          The secret must be defined separately in `sops.secrets`.
        '';
        example = "futu-opend/login-pwd";
      };
    };

    lang = mkOption {
      type = types.enum [
        "en"
        "chs"
      ];
      default = "chs";
      description = "FutuOpenD language.";
    };

    logLevel = mkOption {
      type = types.enum [
        "no"
        "debug"
        "info"
        "warning"
        "error"
        "fatal"
      ];
      default = "info";
      description = "FutuOpenD log level.";
    };

    logPath = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to generate FutuOpenD logs. Omit to use FutuOpenD's default path.";
      example = "/var/log/futu-opend";
    };

    pushProtoType = mkOption {
      type = types.enum [
        0
        1
      ];
      default = 0;
      description = "API push protocol format: 0 = protobuf, 1 = JSON.";
    };

    qotPushFrequency = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Data push frequency in milliseconds. Candlesticks and timeframes are not included. Null means unlimited.";
      example = 1000;
    };

    telnet = {
      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Telnet listening address. Null omits the setting.";
        example = "127.0.0.1";
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Telnet listening port. Null disables/omits the setting.";
        example = 22222;
      };
    };

    rsaPrivateKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Private-key file path for API protocol encryption. Null disables encryption.";
      example = "/var/lib/futu-opend/rsa_private_key.pem";
    };

    priceReminderPush = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to receive price reminder pushes.";
    };

    autoHoldQuoteRight = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically grab highest quote right after being kicked.";
    };

    futureTradeApiTimeZone = mkOption {
      type = types.str;
      default = "UTC+8";
      description = "Time zone for futures trading API. Required by FutuOpenD when trading futures.";
    };

    websocket = {
      ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebSocket listening address. Null omits the setting.";
        example = "127.0.0.1";
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "WebSocket listening port. Null disables/omits WebSocket support.";
        example = 33333;
      };

      keyMd5 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebSocket authentication key as 32-character MD5 hex.";
        example = "14e1b600b1fd579f47433b88e8d85291";
      };

      privateKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebSocket private-key file path. SSL requires both privateKey and cert.";
        example = "/var/lib/futu-opend/websocket.key";
      };

      cert = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebSocket certificate file path. SSL requires both privateKey and cert.";
        example = "/var/lib/futu-opend/websocket.crt";
      };
    };

    pdtProtection = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Pattern Day Trade protection for FUTU US.";
    };

    dtcallConfirmation = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Day-Trading Call warning for FUTU US.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          builtins.length (
            builtins.filter (value: value != null) [
              cfg.loginAccount
              cfg.sops.loginAccount
            ]
          ) == 1;
        message = "Exactly one of services.futu-opend.loginAccount or services.futu-opend.sops.loginAccount must be set.";
      }
      {
        assertion =
          builtins.length (
            builtins.filter (value: value != null) [
              cfg.loginPwdMd5
              cfg.loginPwd
              cfg.sops.loginPwdMd5
              cfg.sops.loginPwd
            ]
          ) == 1;
        message = "Exactly one of services.futu-opend.loginPwdMd5, loginPwd, sops.loginPwdMd5, or sops.loginPwd must be set.";
      }
      {
        assertion = (cfg.websocket.privateKey == null) == (cfg.websocket.cert == null);
        message = "services.futu-opend.websocket.privateKey and services.futu-opend.websocket.cert must be set together.";
      }
    ];

    sops.templates = mkIf hasSopsSecrets {
      "FutuOpenD.xml".content = builtins.readFile configFile;
    };

    systemd.services.futu-opend = {
      description = "FutuOpenD gateway service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = rec {
        ExecStart = "${lib.getExe' cfg.package "FutuOpenD"} -cfg_file ${configPath}";
        LoadCredential = mkIf hasSopsSecrets [
          "FutuOpenD.xml:${config.sops.templates."FutuOpenD.xml".path}"
        ];
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "futu-opend";
        WorkingDirectory = "/var/lib/${StateDirectory}";
      };
    };
  };
}
