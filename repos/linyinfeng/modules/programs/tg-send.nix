{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.tg-send;

  tg-send = pkgs.writeScriptBin "tg-send" ''
    export TELOXIDE_TOKEN="$(cat "${cfg.tokenFile}")"
    ${cfg.package}/bin/tg-send ${lib.escapeShellArgs cfg.extraOptions} "$@"
  '';
in
{

  options.programs.tg-send = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable tg-send.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.linyinfeng.tg-send;
      defaultText = "pkgs.nur.repos.linyinfeng.tg-send";
      description = ''
        tg-send derivation to use.
      '';
    };

    tokenFile = mkOption {
      type = types.str;
      default = null;
      description = ''
        Bot token file for tg-send.
      '';
    };

    extraOptions = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        Extra options passed to tg-send command line.
      '';
    };

    wrapped = mkOption {
      type = types.str;
      default = "${tg-send}/bin/tg-send";
      readOnly = true;
      description = ''
        tg-send program with configuration.
      '';
    };
  };

  config =
    mkIf (cfg.enable) {
      environment.systemPackages = [
        tg-send
      ];
    };
}
