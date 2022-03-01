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

      logind.lidSwitch = "ignore";
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
        rbw
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

    networking.networkmanager = {
      enable = true;

      dispatcherScripts = [
        {
          source =
            let
              grep = "${pkgs.gnugrep}/bin/grep";
              nmcli = "${pkgs.networkmanager}/bin/nmcli";
            in pkgs.writeShellScript "disable_wifi_on_ethernet" ''
              export LC_ALL=C

              enable_disable_wifi ()
              {
                  result=$(${nmcli} dev | ${grep} "ethernet" | ${grep} -w "connected")
                  if [ -n "$result" ]; then
                      ${nmcli} radio wifi off
                  else
                      ${nmcli} radio wifi on
                  fi
              }

              if [ "$2" = "up" ]; then
                  enable_disable_wifi
              fi

              if [ "$2" = "down" ]; then
                  enable_disable_wifi
              fi
            '';
          type = "basic";
        }
      ];
    };
    programs.nm-applet.enable = true;
    programs.steam.enable = true;

    # NOTE: needed for home emacs configuration
    nixpkgs.config.input-fonts.acceptLicense = true;
  };
}
