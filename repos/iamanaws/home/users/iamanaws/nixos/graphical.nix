{
  lib,
  pkgs,
  hostConfig,
  ...
}:
lib.optionalAttrs (hostConfig.isGraphical && hostConfig.isLinux) {
  imports = [ ../../../shared/services/flatpak.nix ];

  home.packages = with pkgs; [
    bitwarden-desktop
    cutter
    # gramps
    pcmanfm
  ];

  services.flatpak.packages = lib.optionals (hostConfig.device.hostname == "goliath") [
    # rec {
    #   appId = "com.hypixel.HytaleLauncher";
    #   sha256 = "sha256-pMZyFtwlGTvCcClvK/dr42+Kvv6ZPhRCgH3iGTgxxHI=";
    #   bundle = "${pkgs.fetchurl {
    #     url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
    #     inherit sha256;
    #   }}";
    # }
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.whitesur-cursors;
    name = "WhiteSur-cursors";
    x11.enable = true;
  };

  gtk = {
    enable = true;
    # GTK4 / libadwaita color scheme
    colorScheme = "dark";

    iconTheme = {
      name = "kuyen-icons";
      package = pkgs.kuyen-icons.overrideAttrs (old: {
        propagatedBuildInputs = [ pkgs.adwaita-icon-theme ];
        postInstall = ''
          substituteInPlace $out/share/icons/kuyen-icons/index.theme \
            --replace-fail 'Inherits=breeze,breeze-dark' 'Inherits=Adwaita'

          find $out/share/icons/kuyen-icons -type l -delete
        '';
      });
    };

    # GTK2 / GTK3 themes
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  programs = {
    imv.enable = true;
    zathura.enable = true;

    rofi = {
      enable = true;
      # font = "CascadiaCode";
      theme = "Arc-Dark";
      extraConfig = {
        show-icons = true;
      };
    };
  };

  # mimeApps - find / -name '*.desktop'
  xdg = {
    portal = {
      enable = true;
      extraPortals =
        with pkgs;
        [
          gnome-keyring
          xdg-desktop-portal-gtk
        ]
        ++ lib.optionals hostConfig.hyprland [
          xdg-desktop-portal-hyprland
        ];

      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      }
      // lib.optionalAttrs hostConfig.hyprland {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Print" = "gtk";
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/octet-stream" = [ "re.rizin.cutter.desktop" ];
        "application/pdf" = [
          "org.pwmt.zathura.desktop"
          "cursor.desktop"
        ];
        "application/json" = [ "cursor.desktop" ];

        "inode/directory" = [ "thunar.desktop" ];

        "image/*" = [ "imv.desktop" ];
        "image/gif" = [ "imv.desktop" ];
        "image/jpeg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
        "image/svg+xml" = [ "imv.desktop" ];
        "image/webp" = [ "imv.desktop" ];

        "text/*" = [ "cursor.desktop" ];
        "text/html" = [ "cursor.desktop" ];
        "text/plain" = [ "cursor.desktop" ];

        "video/*" = [ "mpv.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
        "video/ogg" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
      };
    };

    userDirs = {
      enable = true;
      # createDirectories = true;
      # desktop = "$HOME/desktop";
      download = "$HOME/downloads";
      # templates = "$HOME/templates";
      # publicShare = "$HOME/public";
      documents = "$HOME/files/documents";
      music = "/run/media/iamanaws/DATA/Music/FLAC";
      pictures = "$HOME/files/media/pictures";
      videos = "$HOME/files/media/videos";
      extraConfig = {
        #XDG_MISC_DIR = "$HOME/misc";
        #XDG_GAMES_DIR = "$HOME/games";
        #XDG_WALLPAPERS_DIR = "$HOME/repos/dotfiles/media/shared/wallpapers";
      };
    };
  };

}
