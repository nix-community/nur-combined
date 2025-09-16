# Full desktop
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.full;
in

{
  imports = [ ./desktop.nix ];

  options.abszero.profiles.full.enable = mkExternalEnableOption config "full profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.desktop.enable = true;
      hardware.keyboard.halo65.enable = true;
      boot.plymouth.enable = true;
      virtualisation = {
        act.enable = true;
        libvirtd.enable = true;
      };
      i18n.inputMethod.fcitx5.enable = true;
      services = {
        kanata.enable = true;
        printing.enable = true;
        rclone = {
          enable = true;
          enableFileSystems = true;
        };
      };
      programs = {
        # pot.enable = true;
        steam.enable = true;
        wireshark.enable = true;
      };
    };

    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-qt5-1.1.07"
    ];

    virtualisation.waydroid.enable = true;

    services = {
      flatpak.enable = true;
      gnome.gnome-keyring.enable = true; # For storing vscode auth token
      protonmail-bridge.enable = true;
    };

    xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];

    programs = {
      dconf.enable = true;
      kdeconnect.enable = true;
      nix-ld.enable = true;
    };

    environment = {
      defaultPackages = [ ];
      systemPackages = with pkgs; [
        anki-wayland
        aseprite
        collector
        ffmpeg-full
        gh
        git-absorb
        git-secret
        gnome-solanum
        goldendict-ng
        hyperfine
        inkscape
        inotify-tools
        jetbrains.idea-community
        jq
        kooha
        libreoffice-qt
        lutris
        nudoku
        obsidian
        osu-lazer-bin
        proton-pass
        protonvpn-gui
        taisei
        tenacity
        unzip
        ventoy-full-qt
        vesktop
        vscode
        waydroid-helper
        wev
        wget
        xorg.xeyes
        zen-browser
        zip
        zotero
      ];
    };
  };
}
