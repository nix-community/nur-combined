{ config, pkgs, lib, ... }:
let
  cfg = config.services.shadowsocks-rust;

  json = pkgs.formats.json { };
  configFile = json.generate "ssconfig.json" cfg.settings;

  serverType = with lib; types.submodule {
    freeformType = json.type;

    options = {
      passwordFile = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };
in {
  options.services.shadowsocks-rust = with lib; {
    package = mkPackageOption pkgs "shadowsocks-rust" { };

    servers = mkOption {
      type = types.listOf serverType;
      default = [ ];
    };

    settings = mkOption {
      type = json.type;
      default = { };
    };

    client = {
      enable = mkEnableOption "shadowsocks-rust client";

      localAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
      };
      localPort = mkOption {
        type = types.port;
        default = 1080;
      };
    };

    server = {
      enable = mkEnableOption "shadowsocks-rust server";
    };
  };

  config = let
    processConfig = let
      jqExpr = let
        mkServerExpr = idx: serverConfig: let
          passwordFileExpr = if serverConfig.passwordFile != null
            then ".servers[${toString idx}].password = \\\"$(head -n1 ${serverConfig.passwordFile})\\\""
            else ".";
        in "${passwordFileExpr}";
        serversExpr = lib.concatStringsSep " | " (lib.imap0 mkServerExpr cfg.servers);
      in ". | ${serversExpr}";
    in pkgs.writeShellScript "process-config" ''
      out="$1"

      ${pkgs.jq}/bin/jq "${jqExpr}" ${configFile} > $out
    '';

    baseService = {
      description = "ShadowSocks-Rust Client";
      documentation = [
        "https://github.com/shadowsocks/shadowsocks-rust"
      ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${processConfig} /run/shadowsocks-rust/config.json
      '';

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        RuntimeDirectory = "shadowsocks-rust";
      };
    };
  in with lib; mkMerge [
    {
      services.shadowsocks-rust = {
        settings = {
          version = 1;

          servers = mkIf (cfg.servers != [ ]) (map (serverConfig: let
            normalizedServerConfig = builtins.removeAttrs serverConfig [ "passwordFile" ];
            resolvedServerConfig = normalizedServerConfig;
          in resolvedServerConfig) cfg.servers);
        };
      };
    }

    (mkIf cfg.client.enable {
      systemd.services.shadowsocks-rust-client = mkMerge [
        baseService
        {
          serviceConfig.ExecStart = "${cfg.package}/bin/sslocal --log-without-time --config /run/shadowsocks-rust/config.json --local-addr ${cfg.client.localAddress}:${toString cfg.client.localPort}";
        }
      ];
    })

    (mkIf cfg.server.enable {
      systemd.services.shadowsocks-rust-server = mkMerge [
        baseService
        {
          serviceConfig.ExecStart = "${cfg.package}/bin/ssserver --log-without-time --config /run/shadowsocks-rust/config.json";
        }
      ];
    })
  ];
}
