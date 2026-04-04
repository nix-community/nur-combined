{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.containerPresets.open-webui;
in
{
  options.containerPresets.open-webui = {
    enable = lib.mkEnableOption "Open WebUI NixOS service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Host address to bind to";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      description = "Directory for Open WebUI state";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.open-webui;
      defaultText = lib.literalExpression "pkgs.open-webui";
      description = "The open-webui package to use";
    };

    ollamaBaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OLLAMA_BASE_URL environment variable; null to use Open WebUI's default";
    };

    openFirewall = lib.mkEnableOption "Open firewall for Open WebUI port";

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables passed to the Open WebUI service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      inherit (cfg)
        port
        host
        stateDir
        package
        ;
      openFirewall = cfg.openFirewall;
      environment =
        cfg.environment
        // lib.optionalAttrs (cfg.ollamaBaseUrl != null) {
          OLLAMA_BASE_URL = cfg.ollamaBaseUrl;
        };
    };
  };
}
