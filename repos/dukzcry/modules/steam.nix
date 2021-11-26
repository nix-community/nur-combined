{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.steam;
  xorg = cfg.enable && config.hardware.steam.xorg;
  wayland = cfg.enable && config.hardware.steam.wayland;
in {
  options.hardware.steam = {
    enable = mkEnableOption "Steam headless server";
    xorg = mkEnableOption "via X.Org";
    wayland = mkEnableOption "via Wayland";
    autorun = mkEnableOption "run by default";
    user = mkOption {
      type = types.str;
    };
    devid = mkOption {
      type = types.str;
      example = "0000:07:00.0,1";
    };
    resolution = mkOption {
      type = types.str;
      default = "1920x1080";
    };
  };

  config = mkMerge [

   (mkIf cfg.enable {
    programs.steam.enable = true;
    hardware.pulseaudio.enable = true;
   })
   (mkIf xorg {
      boot.extraModprobeConfig = ''
        options amdgpu virtual_display=${cfg.devid}
      '';
      services.xserver.enable = true;
      services.xserver.autorun = cfg.autorun;
      services.xserver.screenSection = ''
        SubSection "Display"
          Depth  24
          Modes  "${cfg.resolution}"
        EndSubSection
      '';
      services.xserver.displayManager.autoLogin.enable = true;
      services.xserver.displayManager.autoLogin.user = cfg.user;
      services.xserver.displayManager.defaultSession = "none+i3";
      services.xserver.windowManager.i3.enable = true;
      services.xserver.windowManager.i3.extraSessionCommands = ''
        exec ${pkgs.x11vnc}/bin/x11vnc -forever &
        exec steam &
      '';
   })
   (mkIf wayland {
      programs.sway.enable = true;
      programs.sway.extraSessionCommands = ''
        export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 sway
      '';
      environment.etc."sway/config.d/gaming.conf".source = pkgs.writeText "gaming.conf" ''
        exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0
        exec steam
        output HEADLESS-1 resolution ${cfg.resolution}
      '';
      systemd.user.services.steam = {
        wantedBy = optional cfg.autorun "default.target";
        description = "Steam headless server";
        path = [ "/run/current-system/sw" ];
        serviceConfig = {
          ExecStart = "/run/current-system/sw/bin/sway";
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
  ];

}
