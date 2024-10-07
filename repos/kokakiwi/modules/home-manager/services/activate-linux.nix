{ config, pkgs, lib, ... }:
let
  cfg = config.services.activate-linux;

  toConfig = let
    mkValueString = v:
      if lib.isInt v || lib.isFloat v || lib.isString v || lib.isBool v || lib.isPath v
        then lib.strings.toJSON v
      else
        abort "activate-linux.toConfig: type ${lib.typeOf v} is not supported";

    mkKeyValue = k: v:
      "${lib.escape [ "=" ] k} = ${mkValueString v};";
  in lib.generators.toKeyValue {
    inherit mkKeyValue;
  };

  configFormat = {
    type = with lib.types; let
      valueType = nullOr (oneOf [
        bool
        int
        float
        str
        path
      ]);
    in attrsOf valueType;

    generate = name: data: let
      content = toConfig data;
    in pkgs.writeText name content;
  };

  configModule = with lib; types.submodule ({ config, ... }: {
    freeformType = configFormat.type;
    options = let
      mkStringOption = description: args: mkOption ({
        type = with types; nullOr str;
        default = null;
        inherit description;
      } // args);
      mkIntOption = description: args: mkOption ({
        type = with types; nullOr int;
        default = null;
        inherit description;
      } // args);
      mkFloatOption = description: args: mkOption ({
        type = with types; nullOr float;
        default = null;
        inherit description;
      } // args);
      mkBoolOption = description: args: mkOption ({
        type = with types; nullOr bool;
        default = null;
        inherit description;
      } // args);

      textColor = types.submodule {
        options = {
          red = mkFloatOption "Custom color (red)" { };
          green = mkFloatOption "Custom color (green)" { };
          blue = mkFloatOption "Custom color (blue)" { };
          alpha = mkFloatOption "Custom color (alpha)" { };
        };
      };
    in {
      text-title = mkStringOption "Custom main message" { };
      text-message = mkStringOption "Custom secondary message" { };
      text-preset = mkStringOption "Text preset" { };

      text-font = mkStringOption "Custom font" { };
      text-bold = mkBoolOption "Enable bold text" { };
      text-italic = mkBoolOption "Enable italic text" { };

      text-color = mkOption {
        type = textColor;
        default = { };
      };
      text-color-r = mkFloatOption "Custom color (red)" {
        default = config.text-color.red;
      };
      text-color-g = mkFloatOption "Custom color (green)" {
        default = config.text-color.green;
      };
      text-color-b = mkFloatOption "Custom color (blue)" {
        default = config.text-color.blue;
      };
      text-color-a = mkFloatOption "Custom color (alpha)" {
        default = config.text-color.alpha;
      };

      overlay-width = mkIntOption "Custom overlay width" { };
      overlay-height = mkIntOption "Custom overlay height" { };
      scale = mkFloatOption "Custom scaling" { };

      bypass-compositor = mkBoolOption "Skip compositor (only works for compliant compositors)" { };
    };
  });

  configFile = let
    metaKeys = [
      "text-color"
    ];
    config = lib.removeAttrs cfg.config metaKeys;
    cleanedConfig = lib.filterAttrs (name: value: value != null) config;
  in configFormat.generate "activate-linux-config" cleanedConfig;
in {
  options.services.activate-linux = with lib; {
    enable = mkEnableOption "The \"Activate Windows\" watermark ported to Linux";
    package = mkPackageOption pkgs "activate-linux" { };

    config = mkOption {
      type = configModule;
      default = { };
    };
  };

  config = with lib; mkIf cfg.enable {
    systemd.user.services.activate-linux = {
      Unit = {
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/activate-linux --config-file ${configFile}";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
