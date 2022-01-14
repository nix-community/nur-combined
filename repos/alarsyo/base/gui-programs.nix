{ pkgs, lib, config, options, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    optional
  ;
in
{
  options.my.gui = {
    enable = mkEnableOption "System has some kind of screen attached";
    isNvidia = mkEnableOption "System a NVIDIA GPU";
  };

  config = mkIf config.my.gui.enable {
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

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        element-desktop
        feh
        firefox
        ffmpeg
        gimp
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
      ;

      inherit (pkgs.gnome) nautilus;

      inherit (pkgs.unstable) discord;
    };

    networking.networkmanager.enable = true;
    programs.nm-applet.enable = true;
    programs.steam.enable = true;

    # NOTE: needed for home emacs configuration
    nixpkgs.config.input-fonts.acceptLicense = true;
  };
}
