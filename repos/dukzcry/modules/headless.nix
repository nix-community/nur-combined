{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.headless;
  resolution = head cfg.resolutions;
in {
  options.services.headless = {
    xorg = mkEnableOption "via X.Org";
    wayland = mkEnableOption "via Wayland";
    autorun = mkEnableOption "run by default";
    user = mkOption {
      type = types.str;
    };
    commands = mkOption {
      type = types.str;
      default = "";
    };
    dummy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable monitor emulation";
    };
    resolutions = mkOption {
      type = types.listOf types.attrs;
      default = optionals cfg.dummy [ { x = 1920; y = 1080; } ];
    };
    devid = mkOption {
      type = types.str;
      example = "0000:07:00.0,1";
    };
    output = mkOption {
      type = types.str;
      default = if cfg.dummy then "HEADLESS-1" else "HDMI-A-1";
    };
  };
  config = mkMerge [
    (mkIf (cfg.xorg && cfg.dummy) {
      boot.extraModprobeConfig = ''
        options amdgpu virtual_display=${cfg.devid}
      '';
    })
    (mkIf cfg.xorg {
      services.xserver.enable = true;
      services.xserver.autorun = cfg.autorun;
      services.xserver.resolutions = cfg.resolutions;
      services.xserver.displayManager.autoLogin.enable = true;
      services.xserver.displayManager.autoLogin.user = cfg.user;
      services.xserver.displayManager.defaultSession = "none+i3";
      services.xserver.windowManager.i3.enable = true;
      services.xserver.windowManager.i3.extraSessionCommands = ''
        exec ${pkgs.x11vnc}/bin/x11vnc -forever &
        ${cfg.commands}
      '';
    })
    (mkIf (cfg.wayland && cfg.dummy) {
      programs.sway.extraSessionCommands = ''
        export WLR_BACKENDS=headless sway
      '';
      systemd.user.services.headless = {
        wantedBy = optional cfg.autorun "default.target";
        description = "Graphical headless server";
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "sway" ''
            . /etc/set-environment
            sway
          '';
        };
      };
      # https://github.com/NixOS/nixpkgs/issues/3702
      system.activationScripts = {
        enableLingering = ''
          rm -r /var/lib/systemd/linger
          mkdir /var/lib/systemd/linger
          touch /var/lib/systemd/linger/${cfg.user}
        '';
      };
    })
    (mkIf (cfg.wayland && !cfg.dummy) {
      services.xserver.enable = true;
      services.xserver.autorun = cfg.autorun;
      services.xserver.displayManager.autoLogin.enable = true;
      services.xserver.displayManager.autoLogin.user = cfg.user;
      services.xserver.displayManager.defaultSession = "sway";
    })
    (mkIf cfg.wayland {
      programs.sway.enable = true;
      environment.etc."sway/config.d/headless.conf".source = pkgs.writeText "headless.conf" (''
        exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0
        ${cfg.commands}
      '' + optionalString (cfg.resolutions != []) ''
        output ${cfg.output} resolution ${toString resolution.x}x${toString resolution.y}
      '');
    })
  ];
}
