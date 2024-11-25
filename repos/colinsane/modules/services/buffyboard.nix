# buffyboard processes system-wide /dev/input/* events (touchscreen, mouse)
# and outputs events to a virtual input device.
# this plays well with keyboard-only software like getty,
# but for any programs which use both pointer inputs and keyboard inputs (e.g. desktop environments)
# you likely want to instruct them to ignore the buffyboard device, else clicking or tapping might trigger
# both a mouse event *and* an undesired keyboard event via buffyboard.
#
# for sway, add to ~/.config/sway/config: `input "26214:25209:rd" events disabled`
#
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.buffyboard;
  ini = pkgs.formats.ini { };
in
{
  options.sane.services.buffyboard = with lib; {
    enable = mkEnableOption "buffyboard framebuffer keyboard";
    package = mkPackageOption pkgs "buffybox" {};
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Extra CLI arguments to pass to buffyboard.
      '';
      example = [
        "--geometry=1920x1080@640,0"
        "--dpi=192"
        "--rotate=2"
        "--verbose"
      ];
    };
    settings = mkOption {
      type = types.submodule {
        freeformType = ini.type;
        options.theme.default = mkOption {
          type = types.either types.str (types.enum [
            "adwaita-light"
            "adwaita-dark"
            "breezy-light"
            "breezy-dark"
            "nord-light"
            "nord-dark"
            "pmos-light"
            "pmos-dark"
          ]);
          default = "breezy-dark";
          description = ''
            Selects the default theme on boot. Can be changed at runtime to the alternative theme.
          '';
        };
        options.input.pointer = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable or disable the use of a hardware mouse or other pointing device.
          '';
        };
        options.input.touchscreen = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable or disable the use of the touchscreen.
          '';
        };
        options.quirks.fbdev_force_refresh = mkOption {
          type = types.bool;
          default = false;
          description = ''
            If true and using the framebuffer backend, this triggers a display refresh after every draw operation.
            This has a negative performance impact.
          '';
        };
      };
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];  # for buffyboard.service
    systemd.services.buffyboard = {
      # we need only a single buffyboard instance and it can input to any tty
      wantedBy = [ "getty.target" ];
      before = [ "getty.target" ];
    };

    environment.etc."buffyboard.conf".source = ini.generate "buffyboard.conf" cfg.settings;
  };
}
