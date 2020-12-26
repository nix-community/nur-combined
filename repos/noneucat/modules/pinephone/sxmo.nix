{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.windowManager.sxmo;
  sxmoPkgs = pkgs.nur.repos.noneucat.pinephone.sxmo;
in

{
  options = {
    services.xserver.windowManager.sxmo.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable sxmo as a window manager.";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.session = with sxmoPkgs; [{
      name = "sxmo";
      desktopNames = [ "sxmo" ];
      start = ''
        source ${sxmo-xdm-config}/etc/profile.d/profilesxmo.sh
        ${sxmo-utils}/bin/sxmo_xinit.sh &
        waitPID=$!
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
      alsaUtils # alsactl
      xorg.xmodmap
      xorg.xf86inputsynaptics # synclient
      dbus # dbus-run-session
      dunst
      terminus_font
      gnome-icon-theme
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

      foxtrotgps
      keynav
      mpv
      sxiv
      sacc
      htop
      # TODO: package codemadness-frontends, sfeed
    ]);

    services.xserver.libinput.enable = mkDefault true; # used in lisgd 

    # use NetworkManager and ModemManager
    networking.networkmanager.enable = true;
    systemd.services.ModemManager.enable = true;

    # sxmo-utils: utilities that need setuid
    security.wrappers = {
      sxmo_screenlock.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_screenlock";
      sxmo_setpineled.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_setpineled";
      sxmo_setpinebacklight.source = "${sxmoPkgs.sxmo-utils}/bin/sxmo_setpinebacklight";
    };
  };
}

