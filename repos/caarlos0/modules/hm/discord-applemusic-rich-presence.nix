{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.discord-applemusic-rich-presence;
  flakePkgs = import ../.. { inherit pkgs; };
in
{
  options.services.discord-applemusic-rich-presence = {
    enable = mkEnableOption "discord-applemusic-rich-presence";
    package = mkPackageOption flakePkgs "discord-applemusic-rich-presence" { };
    logFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = ''
        ${config.xdg.cacheHome}/discord-applemusic-rich-presence.log
      '';
      description = ''
        Path to a file to log to. If not specified, no logging will be done.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      launchd.agents.discord-applemusic-rich-presence = {
        enable = true;
        config = {
          ProgramArguments =
            [ "${cfg.package}/bin/discord-applemusic-rich-presence" ];
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = cfg.logFile;
          StandardErrorPath = cfg.logFile;
        };
      };
    })
  ];
}
