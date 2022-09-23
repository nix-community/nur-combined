{ config, lib, ... }: with lib; let
  cfg = config;
  arc'lib = import ../../lib { inherit lib; };
  inherit (arc'lib) floor;
  xvalue = value:
    if isString value then ''"${value}"''
    else if isBool value then ''"${if value then "true" else "false"}"''
    else toString value;
  monitorType = { name, options, config, ... }: {
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
        target = mkOption {
          type = types.int;
        };
        x = mkOption {
          type = types.int;
        };
        y = mkOption {
          type = types.int;
        };
        out = mkOption {
          type = types.attrs;
        };
      };
      size = {
        diagonal = mkOption {
          type = types.float;
          description = "diagonal length in inches";
        };
        width = mkOption {
          type = types.int;
          description = "physical width in mm";
        };
        height = mkOption {
          type = types.int;
          description = "physical height in mm";
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
      dpi.out = let
        x = if options.size.width.isDefined
          then config.width / (config.size.width / mmPerInch)
          else if options.dpi.x.isDefined then config.dpi.x
          else 96;
        y = if options.size.height.isDefined
          then config.height / (config.size.height / mmPerInch)
          else if options.dpi.y.isDefined then config.dpi.y
          else 96;
        scale = if options.dpi.target.isDefined
          then 96.0 / config.dpi.target
          else 1.0;
      in {
        dpi = (config.dpi.out.x + config.dpi.out.y) / 2;
        x = x * scale;
        y = y * scale;
        width = floor (config.width / config.dpi.out.x * mmPerInch);
        height = floor (config.height / config.dpi.out.y * mmPerInch);
      };
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
          DPI = mkIf cfg.nvidia.enable "${toIntString config.dpi.out.x} x ${toIntString config.dpi.out.y}";
          DisplaySize = mkIf (config.dpi.out.x != 96 || config.dpi.out.y != 96) "${toString config.dpi.out.width} ${toString config.dpi.out.height}";
          Primary = mkIf config.primary true;
          Position = "${toString config.x} ${toString config.y}";
          PreferredMode = "${toString config.width}x${toString config.height}";
          Rotate = config.rotation;
        };
        monitorSection = mkMerge (mapAttrsToList (k: v: ''Option "${k}" ${xvalue v}'') config.xserver.options);
      };
    };
  };
  mmPerInch = 25.4;
  toIntString = v: toString (floor v);
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
        Option "monitor-${mon.output}" "${mon.xserver.sectionName}"
      '') config.monitors);
    };
  };
}
