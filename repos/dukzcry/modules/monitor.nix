{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.monitor;
  position' = mode: scale:
    let
      res = toString ((toInt (head (splitString "x" mode))) * scale);
    in (head (splitString "." res));
  monitor' = {
    name = "DP-1";
    setup = "00ffffffffffff0030aee66100000000331e0104b53e22783bb4a5ad4f449e250f5054a10800d100d1c0b30081c081809500a9c081004dd000a0f0703e80302035006d552100001a000000fd00283c858538010a202020202020000000fc004c454e20533238752d31300a20000000ff00564e4135433339420a2020202001f002031bf14e61605f101f05140413121103020123097f0783010000a36600a0f0701f80302035006d552100001a565e00a0a0a02950302035006d552100001ae26800a0a0402e60302036006d552100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f";
    config = {
      enable = true;
      mode = "3840x2160";
      dpi = 144;
    };
  };
in {
  options.hardware.monitor = {
    enable = mkEnableOption ''
      Adoptions for monitor
    '';
    config = mkOption {
      type = types.nullOr types.attrs;
      default = null;
    };
    postswitch = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.ddccontrol.enable = true;
      hardware.i2c.enable = true;
      environment.systemPackages = with pkgs; [ ddcutil ];
    })
    (mkIf (cfg.enable && config.services.xserver.enable) {
      systemd.user.services.autorandr = {
        description = "autorandr start on login";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.autorandr}/bin/autorandr --change";
        };
      };
      services.autorandr = {
        enable = true;
        defaultTarget = if cfg.config != null then "laptop" else "monitor";
        profiles = rec {
          laptop = optionalAttrs (cfg.config != null) {
            fingerprint."${cfg.config.name}" = cfg.config.setup;
            config = {
              "${cfg.config.name}" = cfg.config.config;
              "${monitor'.name}".enable = false;
            };
          };
          monitor = {
            fingerprint = {
              "${monitor'.name}" = monitor'.setup;
            } // optionalAttrs (cfg.config != null) {
              "${cfg.config.name}" = cfg.config.setup;
            };
            config = {
              "${monitor'.name}" = monitor'.config;
            } // optionalAttrs (cfg.config != null) {
              "${cfg.config.name}".enable = false;
            };
          };
          # filter isn't supported before next version of autorandr
          integer = monitor // {
            hooks.postswitch.xrandr = "${pkgs.xorg.xrandr}/bin/xrandr --output ${monitor'.name} --scale 0.5x0.5 --filter nearest";
          };
          both = optionalAttrs (cfg.config != null) {
            fingerprint."${cfg.config.name}" = cfg.config.setup;
            fingerprint."${monitor'.name}" = monitor'.setup;
            config = {
              "${cfg.config.name}" = cfg.config.config;
              "${monitor'.name}" = monitor'.config // {
                position = "${position' cfg.config.config.mode cfg.config.scale}x0";
                primary = true;
              };
            };
          };
        };
      };
    })
  ];
}
