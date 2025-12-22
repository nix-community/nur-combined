{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    optional
    ;
in {
  options.my.gui = {
    enable = mkEnableOption "System has some kind of screen attached";
    isNvidia = mkEnableOption "System a NVIDIA GPU";
  };

  config = mkIf config.my.gui.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    services = {
      xserver = {
        enable = true;
        # NOTE: could use `mkOptionDefault` but this feels more explicit
        videoDrivers =
          if config.my.gui.isNvidia
          then ["nvidia"]
          else options.services.xserver.videoDrivers.default;
        xkb = {
          layout = "fr";
          variant = "us";
        };
      };

      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
        };
      };

      logind.settings.Login.HandleLidSwitch = "suspend";

      printing = {
        enable = true;
        cups-pdf.enable = true;
      };

      udev.packages = [pkgs.chrysalis];
    };

    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        arandr
        chrysalis
        discord
        feh
        ffmpeg
        gimp-with-plugins
        imagemagick
        mpv
        obs-studio
        pavucontrol
        spotify
        telegram-desktop
        thunderbird
        virt-manager
        xcolor
        zathura
        ;

      inherit (pkgs.kdePackages) okular;
    };

    networking.networkmanager.enable = true;
    programs.nm-applet.enable = true;
    programs.steam.enable = true;

    # this is necessary to set GTK stuff in home manager
    # FIXME: better interdependency between this and the home part
    programs.dconf.enable = true;

    # NOTE: needed for home emacs configuration
    nixpkgs.config.input-fonts.acceptLicense = true;
  };
}
