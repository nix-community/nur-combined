{ config, lib, pkgs, ... }: with lib; let
  cfg = config.programs.pulsemixer;
  ini = pkgs.formats.ini { };
  convertValue = value:
    if value == true then "yes"
    else if value == false then "no"
    else toString value;
  valueType = with types; oneOf [ int str bool ];
in {
  options.programs.pulsemixer = {
    enable = mkEnableOption "pulsemixer";

    package = mkOption {
      type = types.package;
      default = pkgs.pulsemixer;
      defaultText = "pkgs.pulsemixer";
    };

    # https://github.com/GeorgeFilipkin/pulsemixer#configuration
    config = {
      general = mkOption {
        type = types.attrsOf valueType;
        default = { };
      };
      ui = mkOption {
        type = types.attrsOf valueType;
        default = { };
      };
      style = mkOption {
        type = with types; attrsOf str;
        default = { };
      };
      renames = mkOption {
        type = with types; attrsOf str;
        default = { };
      };
    };

    configContent = mkOption {
      inherit (ini) type;
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ cfg.package ];
    xdg.configFile."pulsemixer.cfg" = mkIf cfg.enable {
      source = ini.generate "pulsemixer" cfg.configContent;
    };
    programs.pulsemixer = {
      configContent = {
        general = mapAttrs (_: value: mkOptionDefault (convertValue value)) cfg.config.general;
        ui = mapAttrs (_: value: mkOptionDefault (convertValue value)) cfg.config.ui;
        style = mapAttrs (_: mkOptionDefault) cfg.config.style;
        renames = mapAttrs (_: mkOptionDefault) cfg.config.renames;
      };
    };
  };
}
