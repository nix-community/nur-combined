{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.programs.telegram-send;

  telegram-send = pkgs.writeScriptBin "telegram-send" ''
    ${cfg.package}/bin/telegram-send --config "${cfg.configFile}" "$@"
  '';
in
{

  options.programs.telegram-send = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable telegram-send.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.linyinfeng.telegram-send;
      defaultText = "pkgs.nur.repos.linyinfeng.telegram-send";
      description = ''
        Telegram-send derivation to use.
      '';
    };

    configFile = mkOption {
      type = types.str;
      default = null;
      description = ''
        Configuration file for telegram-send.
      '';
    };

    withConfig = mkOption {
      type = types.str;
      default = "${telegram-send}/bin/telegram-send";
      readOnly = true;
      description = ''
        Telegram-send program with configuration.
      '';
    };
  };

  config = mkIf (cfg.enable) { environment.systemPackages = [ telegram-send ]; };
}
