{ config, lib, ... }: with lib; let
  xvalue = value:
    if isString value then ''"${value}"''
    else if isBool value then ''"${if value then "true" else "false"}"''
    else toString value;
  monitorType = { name, config, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      output = mkOption {
        type = types.str;
        default = name;
      };
      source = mkOption {
        type = types.nullOr types.str;
        default =
          if hasPrefix "DP-" config.output then "DisplayPort-1"
          else if hasPrefix "HDMI-" config.output then "HDMI-1"
          else null;
      };
      width = mkOption {
        type = types.int;
      };
      height = mkOption {
        type = types.int;
      };
      primary = mkOption {
        type = types.bool;
        default = false;
      };
      edid = {
        manufacturer = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        model = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        serial = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      dpi = {
        x = mkOption {
          type = types.int;
          default = 96;
        };
        y = mkOption {
          type = types.int;
          default = 96;
        };
      };
      refreshRate = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      x = mkOption {
        type = types.int;
        default = 0;
      };
      y = mkOption {
        type = types.int;
        default = 0;
      };
      rotation = mkOption {
        type = types.enum [ "normal" "inverted" "left" "right" ];
        default = "normal";
      };
      nvidia = {
        options = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
        metaMode = mkOption {
          type = types.str;
        };
      };
      xserver = {
        options = mkOption {
          type = types.attrsOf types.unspecified;
          default = { };
        };
        sectionName = mkOption {
          type = types.str;
          default = "Monitor${name}";
        };
        monitorSection = mkOption {
          type = types.lines;
          default = "";
        };
        monitorSectionRaw = mkOption {
          type = types.str;
          default = ''
            Section "Monitor"
              Identifier "${config.xserver.sectionName}"
              ${config.xserver.monitorSection}
            EndSection
          '';
        };
      };
      viewport = {
        width = mkOption {
          type = types.int;
          default =
            if config.rotation == "normal" || config.rotation == "inverted" then config.width
            else config.height;
        };
        height = mkOption {
          type = types.int;
          default =
            if config.rotation == "normal" || config.rotation == "inverted" then config.height
            else config.width;
        };
      };
    };
    config = {
      nvidia = {
        options = {
          Rotation = mkIf (config.rotation != "normal") {
            inverted = "180";
            left = "90";
            right = "270";
          }.${config.rotation};
        };
        metaMode = let
          modename =
            "${toString config.width}x${toString config.height}"
            + optionalString (config.refreshRate != null) "_${toString config.refreshRate}";
          options = mapAttrsToList (k: v: "${k}=${v}") config.nvidia.options;
          optionsStr = concatStringsSep ", " options;
        in mkDefault (
          "${config.output}: ${modename}+${toString config.x}+${toString config.y}"
          + optionalString (config.nvidia.options != { }) " { ${optionsStr} }"
        );
      };
      xserver = {
        options = {
          Enable = mkIf (!config.enable) false;
          DPI = "${toString config.dpi.x} x ${toString config.dpi.y}";
          Primary = mkIf config.primary true;
          Position = "${toString config.x} ${toString config.y}";
          PreferredMode = "${toString config.width}x${toString config.height}";
          Rotate = config.rotation;
        };
        monitorSection = mkMerge (mapAttrsToList (k: v: ''Option "${k}" ${xvalue v}'') config.xserver.options);
      };
    };
  };
in {
  options = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorType);
    };

    nvidia = {
      enable = mkEnableOption "nvidia";
      metaModes = mkOption {
        type = types.str;
      };
    };

    xserver = {
      screenSection = mkOption {
        type = types.lines;
        default = "";
      };
      deviceSection = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };
  config = {
    nvidia = {
      metaModes = mkDefault (concatMapStringsSep ", " (mon: mon.nvidia.metaMode) (attrValues config.monitors));
    };
    xserver = {
      screenSection = mkIf config.nvidia.enable ''
        Option "MetaModes" "${config.nvidia.metaModes}"
      '';
      deviceSection = mkMerge (mapAttrsToList (_: mon: ''
        Option "Monitor-${mon.output}" "${mon.xserver.sectionName}"
      '') config.monitors);
    };
  };
}
