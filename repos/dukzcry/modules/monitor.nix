{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.monitor;
  position' = mode: scale:
    let
      res = toString ((toInt (head (splitString "x" mode))) * scale);
    in (head (splitString "." res));
in {
  options.hardware.monitor = {
    enable = mkEnableOption ''
      Adoptions for hotplugging monitor
    '';
    laptopConfig = mkOption {
      type = types.nullOr types.attrs;
      default = null;
    };
    monitorConfig = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      example = literalExpression ''
        {
          name = "HDMI-1";
          setup = "<edid>";
          config = {
            enable = true;
            mode = "3840x2160";
            dpi = 144;
          };
      '';
    };
    postswitch = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.user.services.autorandr = {
        description = "autorandr start on login";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${getExe pkgs.autorandr} --change";
        };
      };
      services.autorandr = {
        enable = true;
        defaultTarget = if cfg.laptopConfig != null then "laptop" else "monitor";
        profiles = rec {
          laptop = optionalAttrs (cfg.laptopConfig != null) {
            fingerprint."${cfg.laptopConfig.name}" = cfg.laptopConfig.setup;
            config = {
              "${cfg.laptopConfig.name}" = cfg.laptopConfig.config;
              "${cfg.monitorConfig.name}".enable = false;
            };
          };
          monitor = {
            fingerprint = {
              "${cfg.monitorConfig.name}" = cfg.monitorConfig.setup;
            } // optionalAttrs (cfg.laptopConfig != null) {
              "${cfg.laptopConfig.name}" = cfg.laptopConfig.setup;
            };
            config = {
              "${cfg.monitorConfig.name}" = cfg.monitorConfig.config;
            } // optionalAttrs (cfg.laptopConfig != null) {
              "${cfg.laptopConfig.name}".enable = false;
            };
          };
          # workaround: filter isn't supported before next version of autorandr
          integer = monitor // {
            hooks.postswitch.xrandr = "${getExe pkgs.xorg.xrandr} --output ${cfg.monitorConfig.name} --scale 0.5x0.5 --filter nearest";
          };
          both = optionalAttrs (cfg.laptopConfig != null) {
            fingerprint."${cfg.laptopConfig.name}" = cfg.laptopConfig.setup;
            fingerprint."${cfg.monitorConfig.name}" = cfg.monitorConfig.setup;
            config = {
              "${cfg.laptopConfig.name}" = cfg.laptopConfig.config;
              "${cfg.monitorConfig.name}" = cfg.monitorConfig.config // {
                position = "${position' cfg.laptopConfig.config.mode (cfg.laptopConfig.scale or 1.0)}x0";
                primary = true;
              };
            };
          };
        };
        hooks = {
          postswitch = {
            xrdb = ''
              case "$AUTORANDR_CURRENT_PROFILE" in
                integer)
                  DPI=96
                  SIZE=16
                  ;;
                monitor|both)
                  DPI=144
                  SIZE=32
                  ;;
            '' + optionalString (cfg.laptopConfig != null) ''
                  laptop)
                    DPI=${toString cfg.laptopConfig.dpi}
                    SIZE=${toString cfg.laptopConfig.size}
                    ;;
            '' + ''
                *)
                  echo "Unknown profle: $AUTORANDR_CURRENT_PROFILE"
                  exit 1
              esac
              printf "Xft.dpi:%s\nXcursor.size:%s\n" "$DPI" "$SIZE" | ${getExe pkgs.xorg.xrdb} -merge
            '';
          } // optionalAttrs (cfg.postswitch != null) {
            inherit (cfg) postswitch;
          };
        };
      };
    })
  ];
}
