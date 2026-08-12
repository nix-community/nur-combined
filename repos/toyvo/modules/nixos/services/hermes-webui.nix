{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.hermes-webui;

  hermesAgentPkg = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  pythonEnv = hermesAgentPkg.hermesVenv;
  pythonSitePackages = "${pythonEnv}/lib/python3.12/site-packages";

  hermes-webui-script = pkgs.writeShellScriptBin "hermes-webui" ''
    export HERMES_WEBUI_AGENT_DIR="${inputs.hermes-agent}"
    export PYTHONPATH="${pythonSitePackages}:${inputs.hermes-webui}:$PYTHONPATH"
    cd "${inputs.hermes-webui}"
    exec ${pythonEnv}/bin/python3 server.py "$@"
  '';
in
{
  options.services.hermes-webui = {
    enable = lib.mkEnableOption "Hermes WebUI (nesquena/hermes-webui)";

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to bind the webui to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "Port for the webui.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hermes";
      description = "State directory (HERMES_HOME).";
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the webui password.
        If set, the HERMES_WEBUI_PASSWORD env var is populated from this file.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hermes-webui = {
      description = "Hermes WebUI";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "hermes-agent.service"
      ];
      wants = [ "hermes-agent.service" ];

      environment = {
        HOME = cfg.stateDir;
        HERMES_HOME = "${cfg.stateDir}/.hermes";
        HERMES_WEBUI_HOST = cfg.host;
        HERMES_WEBUI_PORT = toString cfg.port;
        HERMES_WEBUI_STATE_DIR = "${cfg.stateDir}/.hermes/webui-mvp";
      }
      // lib.optionalAttrs (cfg.passwordFile != null) {
        HERMES_WEBUI_PASSWORD_FILE = cfg.passwordFile;
      };

      serviceConfig = {
        User = config.services.hermes-agent.user or "hermes";
        Group = config.services.hermes-agent.group or "hermes";
        Restart = "always";
        RestartSec = "5s";
        LoadCredential = lib.mkIf (cfg.passwordFile != null) [
          "webui-password:${cfg.passwordFile}"
        ];
      };

      script =
        lib.optionalString (cfg.passwordFile != null) ''
          export HERMES_WEBUI_PASSWORD=$(cat "${cfg.passwordFile}")
        ''
        + ''
          exec ${hermes-webui-script}/bin/hermes-webui
        '';
    };
  };
}
