{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.sunshine;
  xorg = cfg.enable && config.services.sunshine.xorg;
  wayland = cfg.enable && config.services.sunshine.wayland;
  sunshine = pkgs.nur.repos.dukzcry.sunshine;
in {
  options.services.sunshine = {
    enable = mkEnableOption "Sunshine headless server";
    xorg = mkEnableOption "via X.Org";
    wayland = mkEnableOption "via Wayland";
    autorun = mkEnableOption "run by default";
    resolution = mkOption {
      type = types.str;
      default = "1920x1080";
    };
    user = mkOption {
      type = types.str;
    };
  };

  config = mkMerge [

   (mkIf cfg.enable {
      environment.systemPackages = [ sunshine ];
      hardware.pulseaudio.enable = true;
      hardware.uinput.enable = true;
      users.extraUsers.${cfg.user}.extraGroups = [ "uinput" ];
      security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${sunshine}/bin/sunshine";
      };
      system.activationScripts = {
        sunshine = ''
          mkdir -p /etc/sunshine
          chown -R ${cfg.user} /etc/sunshine
          chmod u+w -R /etc/sunshine
        '';
      };
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
        exec sunshine &
      '';
   })
   (mkIf wayland {
      programs.sway.enable = true;
      programs.sway.extraSessionCommands = ''
        export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 sway
      '';
      environment.etc."sway/config.d/gaming.conf".source = pkgs.writeText "gaming.conf" ''
        exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0
        exec sunshine
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
