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
      virtualisation = {
        act.enable = true;
        libvirtd.enable = true;
      };
      i18n.inputMethod.fcitx5.enable = true;
      services = {
        kanata.enable = true;
        rclone = {
          enable = true;
          enableFileSystems = true;
        };
        wluma.enable = true;
      };
      programs = {
        neovim.enable = true;
        pot.enable = true;
        steam.enable = true;
        wireshark.enable = true;
      };
    };

    boot.plymouth.enable = true;

    virtualisation.waydroid.enable = true;

    services = {
      flatpak.enable = true;
      gnome.gnome-keyring.enable = true; # For storing vscode auth token
      mpd.enable = true;
      protonmail-bridge.enable = true;
    };

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
        ffmpeg-full
        gh
        git-absorb
        git-secret
        gnome-solanum
        goldendict-ng
        inkscape
        jetbrains.idea-community
        jq
        katawa-shoujo-re-engineered
        kooha
        libreoffice-qt
        obsidian-ime
        osu-lazer-bin
        proton-pass
        protonvpn-gui
        taisei
        tenacity
        unzip
        (ventoy.override {
          defaultGuiType = "qt5";
          withQt5 = true;
        })
        vesktop
        vscode
        wev
        wget
        win2xcur
        xorg.xeyes
        zen-browser
        zip
      ];
    };
  };
}
