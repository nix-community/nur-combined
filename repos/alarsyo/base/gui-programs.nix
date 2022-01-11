{ pkgs, lib, config, options, ... }:
{
  options.my.gui = {
    enable = lib.mkEnableOption "System has some kind of screen attached";
    isNvidia = lib.mkEnableOption "System a NVIDIA GPU";
  };

  config = lib.mkIf config.my.gui.enable {
    my.displayManager.sddm.enable = true;

    services = {
      xserver = {
        enable = true;
        # NOTE: could use `mkOptionDefault` but this feels more explicit
        videoDrivers = if config.my.gui.isNvidia then [ "nvidia" ]
                       else options.services.xserver.videoDrivers.default;
        windowManager.i3.enable = true;
        layout = "fr";
        xkbVariant = "us";
        libinput.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      element-desktop
      feh
      firefox
      ffmpeg
      gimp
      gnome.nautilus
      imagemagick
      mpv
      obs-studio
      pavucontrol
      slack
      spotify
      tdesktop
      teams
      thunderbird
      virt-manager
      zathura

      unstable.discord
    ];

    networking.networkmanager.enable = true;
    programs.nm-applet.enable = true;
    programs.steam.enable = true;

    # NOTE: needed for home emacs configuration
    nixpkgs.config.input-fonts.acceptLicense = true;
  };
}
