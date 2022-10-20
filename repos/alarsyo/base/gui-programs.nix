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
    my.displayManager.sddm.enable = true;

    services = {
      xserver = {
        enable = true;
        # NOTE: could use `mkOptionDefault` but this feels more explicit
        videoDrivers =
          if config.my.gui.isNvidia
          then ["nvidia"]
          else options.services.xserver.videoDrivers.default;
        windowManager.i3.enable = true;
        layout = "fr";
        xkbVariant = "us";
        libinput.enable = true;
      };

      logind.lidSwitch = "ignore";
    };

    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        chrysalis
        element-desktop
        evince
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

      discord = pkgs.unstable.discord.override {nss = pkgs.nss_latest;};
    };

    networking.networkmanager = {
      enable = true;

      dispatcherScripts = [
        {
          source = let
            grep = "${pkgs.gnugrep}/bin/grep";
            nmcli = "${pkgs.networkmanager}/bin/nmcli";
          in
            pkgs.writeShellScript "disable_wifi_on_ethernet" ''
              export LC_ALL=C
              date >> /tmp/disable_wifi_on_ethernet.log
              echo START "$@" >> /tmp/disable_wifi_on_ethernet.log

              beginswith() { case $2 in "$1"*) true;; *) false;; esac; }

              is_ethernet_interface ()
              {
                  local type="$(${nmcli} dev show "$1" | grep 'GENERAL\.TYPE:' | awk '{ print $2 }')"
                  test "$type" = "ethernet" || beginswith enp "$1"
              }

              hotspot_enabled ()
              {
                ${nmcli} dev | ${grep} -q "hotspot"
              }

              if is_ethernet_interface "$1" && ! hotspot_enabled; then
                echo "change in ethernet and not in hotspot mode" >> /tmp/disable_wifi_on_ethernet.log
                if [ "$2" = "up" ]; then
                    echo "turning wifi off" >> /tmp/disable_wifi_on_ethernet.log
                    nmcli radio wifi off
                fi

                if [ "$2" = "down" ]; then
                    echo "turning wifi on" >> /tmp/disable_wifi_on_ethernet.log
                    nmcli radio wifi on
                fi
              fi
              echo END "$@" >> /tmp/disable_wifi_on_ethernet.log
            '';
          type = "basic";
        }
      ];
    };
    programs.nm-applet.enable = true;
    programs.steam.enable = true;

    # this is necessary to set GTK stuff in home manager
    # FIXME: better interdependency between this and the home part
    programs.dconf.enable = true;

    # NOTE: needed for home emacs configuration
    nixpkgs.config.input-fonts.acceptLicense = true;
  };
}
