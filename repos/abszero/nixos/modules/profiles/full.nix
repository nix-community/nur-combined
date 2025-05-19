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
        pot.enable = true;
        steam.enable = true;
        wireshark.enable = true;
      };
    };

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
        # TODO: Switch to anki-qt6 when it is no longer broken on Wayland
        anki-bin-qt6-wayland
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
        obsidian-ime
        osu-lazer-bin
        proton-pass
        protonvpn-gui
        taisei
        tenacity
        unzip
        # TODO: switch to Qt6 when it's supported
        ventoy-full-gtk
        vesktop
        vscode
        wev
        wget
        win2xcur
        xorg.xeyes
        zen-browser
        zip
        zotero
      ];
    };
  };
}
