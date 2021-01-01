{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.windowManager.sxmo;
  sxmoPkgs = pkgs.nur.repos.noneucat.pinephone.sxmo;
in

{
  options = {
    services.xserver.windowManager.sxmo = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Sxmo as a window manager.";
      };

      wallpaperImage = mkOption {
        default = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/766f10e0c93cb1236a85925a089d861b52ed2905/wallpapers/nix-wallpaper-mosaic-blue.png";
          sha256 = "1cbcssa8qi0giza0k240w5yy4yb2bhc1p1r7pw8qmziprcmwv5n5";
        };

        description = ''
          The default image to set as Sxmo's wallpaper.

          This setting will be ignored if ~/.config/sxmo/xinit exists in the user's directory.
        '';
      };

      enablePinePhoneGps = mkOption {
        type = types.bool;
        default = true;
        description = "Set up GPS on the PinePhone modem.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.session = with sxmoPkgs; [{
      name = "sxmo";
      desktopNames = [ "sxmo" ];
      start = ''
        source ${sxmo-xdm-config}/etc/profile.d/sxmo.sh

        # needed for sxmo_gpsutil.sh to make use of gsettings
        FOXTROT_SCHEMAS_PATTERN="${pkgs.foxtrotgps}/share/gsettings-schemas/*"
        FOXTROT_SCHEMAS=( $FOXTROT_SCHEMAS_PATTERN )


        export XDG_DATA_DIRS=$XDG_DATA_DIRS:$FOXTROT_SCHEMAS

        ${pkgs.runtimeShell} ${sxmo-utils}/bin/sxmo_xinit.sh &
        waitPID=$!

        # draw our wallpaper only if xinit is not set
        if [ ! -f $XDG_CONFIG_HOME/sxmo/xinit ]; then
          ${pkgs.feh}/bin/feh --bg-fill -z ${cfg.wallpaperImage}
        fi
      '';
    }];

    environment.systemPackages = with sxmoPkgs; [ 
      lisgd 
      sxmo-dmenu
      sxmo-dwm
      sxmo-st
      sxmo-surf
      sxmo-svkbd
      sxmo-utils
      sxmo-xdm-config
    ] ++ (with pkgs; [
      autocutsel
      alsaUtils # alsactl
      bc
      coreutils
      findutils
      xorg.xmodmap
      xorg.xf86inputsynaptics # synclient
      xorg.xwininfo
      dbus # dbus-run-session
      dunst
      terminus_font
      gnome-icon-theme
      glib
      gsettings-desktop-schemas
      xdotool
      gawk
      xclip
      xsel
      inotify-tools
      conky
      coreutils
      netsurf-browser
      youtube-dl
      v4l-utils
      vis
      libnotify
      libxml2
      lsof

      foxtrotgps
      keynav
      mpv
      sxiv
      sacc
      htop

      nur.repos.noneucat.sfeed
      nur.repos.noneucat.codemadness-frontends
      nur.repos.noneucat.geoclue2-demos
      nur.repos.noneucat.pinephone.megapixels
    ]);

    services.xserver.libinput.enable = mkDefault true; # used in lisgd 

    # use NetworkManager and ModemManager
    networking.networkmanager.enable = true;
    systemd.services.ModemManager.enable = true;

    # Enable gpsd
    services.gpsd.enable = true; 
    services.gpsd.device = "/dev/ttyUSB1";

    # Enable geoclue
    services.geoclue2.enable = true;
    services.geoclue2.enableDemoAgent = false; # we would use this, but it doesn't build for me

    # PinePhone: enable modem
    systemd.services.modem-control.enable = true;

    # PinePhone: GPS
    systemd.services.gps-modem-setup = mkIf cfg.enablePinePhoneGps {
      description = "Set modem up for GPS";
      enable = true;
      path = with pkgs; [ systemd atinout ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          systemctl start ModemManager.service

          # https://www.quectel.com/UploadImage/Downlad/Quectel_LTE_Standard_GNSS_Application_Note_V1.2.pdf
          echo "AT+QGPS=1,30,50,0,2" | atinout - /dev/ttyUSB3 -

          mmcli -m 0 --location-enable-gps-raw --location-enable-gps-nmea # not sure if needed...
        '';
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
      before = [ "gpsd.service" ];
      after = [ "modem-control.service" ];
    };

    # sxmo-utils: utilities that need setuid
    security.wrappers = {
      sxmo_screenlock.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_screenlock";
      sxmo_setpineled.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_setpineled";
      sxmo_setpinebacklight.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_setpinebacklight";
    };
  };
}

