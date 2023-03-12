{ config, lib, ... }: with lib; let
  cfg = config;
  arc'lib = import ../../lib { inherit lib; };
  inherit (arc'lib) floor;
  filterNulls = filterAttrs (_: v: v != null);
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
          type = types.attrsOf (types.nullOr types.str);
          default = { };
        };
        flatPanelOptions = mkOption {
          type = types.attrsOf (types.nullOr types.str);
          default = { };
        };
        metaMode = mkOption {
          type = types.str;
        };
        flatPanelProperties = mkOption {
          type = types.nullOr types.str;
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
        xrandr = {
          flags = mkOption {
            type = with types; attrsOf (oneOf [ str bool ]);
          };
          args = mkOption {
            type = types.listOf types.str;
            default = cli.toGNUCommandLine { } config.xserver.xrandr.flags;
          };
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
      nvidia = let
        options = mapAttrsToList (k: v: "${k}=${v}");
        optionsStr = values: concatStringsSep ", " (options values);
      in {
        options = {
          Rotation = mkIf (config.rotation != "normal") {
            inverted = "180";
            left = "90";
            right = "270";
          }.${config.rotation};
        };
        metaMode = let
          nvopts = filterNulls config.nvidia.options;
          modename =
            "${toString config.width}x${toString config.height}"
            + optionalString (config.refreshRate != null) "_${toString config.refreshRate}";
        in mkDefault (
          "${config.output}: ${modename}+${toString config.x}+${toString config.y}"
          + optionalString (nvopts != { }) " { ${optionsStr nvopts} }"
        );
        flatPanelProperties = let
          values = filterNulls config.nvidia.flatPanelOptions;
          value = "${config.output}: ${optionsStr values}";
        in mkDefault (if values == { } then null else value);
      };
      xserver = {
        options = {
          Enable = mkIf (!config.enable) false;
          DPI = mkIf cfg.nvidia.enable "${toIntString config.dpi.out.x} x ${toIntString config.dpi.out.y}";
          DisplaySize = mkIf (config.dpi.out.x != 96 || config.dpi.out.y != 96) "${toString config.dpi.out.width} ${toString config.dpi.out.height}";
          Primary = mkIf config.primary true;
          Position = mkIf (config.x != 0 || config.y != 0) "${toString config.x} ${toString config.y}";
          PreferredMode = "${toString config.width}x${toString config.height}";
          Rotate = mkIf (config.rotation != "normal") config.rotation;
        };
        monitorSection = mkMerge (mapAttrsToList (k: v: ''Option "${k}" ${xvalue v}'') config.xserver.options);
        xrandr.flags = {
          mode = "${toString config.width}x${toString config.height}";
          pos = "${toString config.x}x${toString config.y}";
          ${if config.refreshRate != null then "refresh" else null} = toString config.refreshRate;
          ${if config.primary then "primary" else null} = true;
          ${if !config.enable then "off" else null} = true;
          ${if config.rotation != "normal" then "rotate" else null} = config.rotation;
        };
      };
    };
  };
  mmPerInch = 25.4;
  toIntString = v: toString (floor v);
  enabledMonitors = attrValues (filterAttrs (_: mon: mon.enable) config.monitors);
in {
  options = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    monitors = mkOption {
      type = types.attrsOf (types.submoduleWith {
        modules = [ monitorType ];
        specialArgs = {
          inherit (config) monitors;
        };
      });
    };

    nvidia = {
      enable = mkEnableOption "nvidia";
      metaModes = mkOption {
        type = types.str;
      };
      flatPanelProperties = mkOption {
        type = types.str;
      };
    };

    dpms = {
      enable = mkEnableOption "DPMS" // {
        default = true;
      };
      standbyMinutes = mkOption {
        type = types.int;
        default = 10;
      };
      screensaverMinutes = mkOption {
        type = types.int;
        default = config.dpms.standbyMinutes;
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
      serverLayoutSection = mkOption {
        type = types.lines;
        default = "";
      };
      xrandr = {
        args = mkOption {
          type = types.listOf types.str;
        };
      };
    };
  };
  config = {
    nvidia = {
      metaModes = mkDefault (concatMapStringsSep ", " (mon: mon.nvidia.metaMode) enabledMonitors);
      flatPanelProperties = mkDefault (concatMapStringsSep ", " (mon: mon.nvidia.flatPanelProperties) (
        filter (mon: mon.nvidia.flatPanelProperties != null) enabledMonitors
      ));
    };
    xserver = {
      screenSection = mkIf config.nvidia.enable (mkMerge [
        ''Option "MetaModes" "${config.nvidia.metaModes}"''
        (mkIf (config.nvidia.flatPanelProperties != "") ''
          Option "FlatPanelProperties" "${config.nvidia.flatPanelProperties}"
        '')
      ]);
      deviceSection = mkMerge (map (mon: ''
        Option "monitor-${mon.output}" "${mon.xserver.sectionName}"
      '') enabledMonitors);
      serverLayoutSection = mkIf config.dpms.enable ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "${toString config.dpms.standbyMinutes}"
        Option "BlankTime" "${toString config.dpms.screensaverMinutes}"
      '';
      xrandr.args = mkAfter (flip concatMap (attrValues config.monitors) (mon:
        [ "--output" mon.output ]
        ++ (if mon.enable then mon.xserver.xrandr.args else [ "--off" ])
      ));
    };
  };
}
