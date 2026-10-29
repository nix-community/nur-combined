{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.magpie;
  common = import ./magpie-common.nix { inherit lib pkgs; };
  shared = common.helpers cfg;
  launcher = pkgs.writeShellScript "magpie-darwin-start" ''
    set -euo pipefail
    ${lib.optionalString (cfg.environmentFile != null) ''
      set -a
      . ${lib.escapeShellArg cfg.environmentFile}
      set +a
    ''}
    ${lib.optionalString (cfg.web.keyFile != null) ''
      export MAGPIE_WEB_KEY="$(< ${lib.escapeShellArg cfg.web.keyFile})"
    ''}
    ${shared.configureCmd null}
    exec ${lib.escapeShellArgs ([ (lib.getExe' cfg.package "magpie") ] ++ shared.serveArgs)}
  '';
in
{
  options.services.magpie = common.commonOptions // {
    logFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching "/.*");
      default = null;
      example = "/tmp/magpie.log";
      description = "Optional path for launchd stdout and stderr logs.";
    };
  };

  config = lib.mkIf cfg.enable {
    inherit (shared) assertions;

    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.magpie = {
      serviceConfig = {
        Label = "com.yetone.magpie.serve";
        ProgramArguments = [ "${launcher}" ];
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ThrottleInterval = 5;
        ProcessType = "Background";
        EnvironmentVariables = lib.mkMerge [
          shared.baseEnvironment
          cfg.environment
        ];
      }
      // lib.optionalAttrs (cfg.logFile != null) {
        StandardOutPath = cfg.logFile;
        StandardErrorPath = cfg.logFile;
      };
    };
  };
}
