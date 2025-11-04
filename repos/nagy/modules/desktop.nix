{
  config,
  pkgs,
  lib,
  nur,
  ...
}:

{
  config = lib.mkIf config.services.xserver.enable {

    # Almost all hosts should have this keymap
    console.keyMap = lib.mkDefault "de";

    # non-root access to the firmware of QMK keyboards
    # hardware.keyboard.qmk.enable = true;

    boot.kernel.sysctl = {
      # This allows a special scape key: alt+print+<key>
      # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
      "kernel.sysrq" = 1;
    };

    console.useXkbConfig = true;

    environment.systemPackages = [
      pkgs.xorg.xcursorthemes
      pkgs.xorg.xwininfo
      pkgs.scrot
      nur.repos.nagy.nsxivBigThumbs
      pkgs.xclip
      pkgs.pulsemixer
      pkgs.poppler-utils # pdf utils
      pkgs.yt-dlp
      (pkgs.zbar.override {
        withXorg = false;
        enableVideo = false;
      })
      pkgs.ffmpeg_7-full
      pkgs.pandoc
      pkgs.gh

      (pkgs.redshift.override { withGeolocation = false; })
    ]
    ++ (lib.optionals config.documentation.dev.enable [
      pkgs.man-pages
      pkgs.glibcInfo # info files for gnu glibc
      pkgs.csvkit
    ]);

    services.xserver = {
      dpi = lib.mkDefault 192;
      # Configure X11 window manager
      displayManager.startx.enable = true;
      enableTearFree = true;
      # logFile = "/dev/null"; # the default
      # windowManager.exwm.enable = true;
      # videoDrivers = [ "amdgpu" ];
      excludePackages = [ pkgs.xterm ];
      # https://askubuntu.com/questions/366308/how-to-make-xset-s-off-survive-a-reboot-12-04
      serverFlagsSection = ''
        Option "BlankTime" "5"
      '';
      # does not work yet
      # autoRepeatDelay = 260;
      # autoRepeatInterval = 40;
    };
    # for wayland compositors
    environment.sessionVariables.XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;

    services.pulseaudio = {
      enable = true;
    };

    services.pipewire = {
      enable = false;
    };

    programs.wireshark = {
      enable = true;
      # package = if config.services.xserver.enable then pkgs.wireshark else pkgs.wireshark-cli;
      # soon  https://github.com/NixOS/nixpkgs/pull/379179
      # usbmon = true;
    };

    environment.etc."X11/Xresources".text = ''
      *.font: -USGC-*
      *.background: #000000
      *.foreground: #ffffff
      Xcursor.size: 48
      Xcursor.theme: whiteglass
    '';
  };
}
