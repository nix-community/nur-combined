# Full graphical session
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.graphical-full;
in

{
  imports = [ ./graphical.nix ];

  options.abszero.profiles.graphical-full.enable =
    mkExternalEnableOption config "graphical-full profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.graphical.enable = true;
      hardware.keyboard.halo65.enable = true;
      boot.plymouth.enable = true;
      virtualisation.act.enable = true;
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

    nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.10" ];

    hardware.keyboard.qmk.enable = true;

    virtualisation.waydroid.enable = true;

    services = {
      flatpak.enable = true;
      protonmail-bridge.enable = true;
    };

    programs = {
      dconf.enable = true;
      kdeconnect.enable = true;
      nix-ld.enable = true;
      wisp.enable = true;
    };

    environment = {
      defaultPackages = [ ];
      systemPackages = with pkgs; [
        anki-wayland
        aseprite
        ayugram-desktop
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
        jetbrains.idea-oss
        jq
        kooha
        libreoffice-qt
        lutris
        minefair
        nautilus
        nudoku
        obsidian
        proton-pass
        protonvpn-gui
        # taisei
        tenacity
        unzip
        ventoy-full
        vesktop
        vscode
        waydroid-helper
        waypipe
        wev
        wget
        xorg.xeyes
        zip
        zotero
      ];
    };
  };
}
