{ pkgs, ... }: {
  imports = [
    ./desktop.nix
    ../hardware/halo65.nix
  ];

  abszero = {
    virtualisation = {
      act.enable = true;
      libvirtd.enable = true;
    };
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      kanata.enable = true;
      rclone = {
        enable = true;
        enableFileSystems = true;
      };
    };
    programs = {
      neovim.enable = true;
      pot.enable = true;
      steam.enable = true;
      wireshark.enable = true;
    };
    i18n.inputMethod.fcitx5.enable = true;
  };

  virtualisation.waydroid.enable = true;

  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true; # For storing vscode auth token
    mpd.enable = true;
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad = {
          clickMethod = "clickfinger";
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
    };
  };

  programs = {
    dconf.enable = true;
    fish.enable = true; # For vendor completions; config is managed by home-manager
    kdeconnect.enable = true;
    nix-ld.enable = true;
    ssh = {
      enableAskPassword = true;
      askPassword = "${pkgs.libsForQt5.ksshaskpass}/bin/ksshaskpass";
    };
    xwayland.enable = true;
  };

  environment = {
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      # TODO: Switch to anki-qt6 when it is no longer broken on Wayland
      anki-bin-qt6
      aseprite
      ffmpeg_5-full
      gh
      git-absorb
      git-secret
      gnome-solanum
      goldendict-ng
      inkscape
      jetbrains.idea-community
      jq
      katawa-shoujo
      kooha
      libreoffice-qt
      neofetch
      obsidian-ime
      protonmail-bridge
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
      wget
      win2xcur
      xorg.xeyes
      zip
    ];
    sessionVariables = {
      # Enable running commands without installation
      # Currently not needed because nix-index is enabled in home-manager
      # NIX_AUTO_RUN = "1";
      # Make Electron apps run in Wayland native mode
      NIXOS_OZONE_WL = "1";
      # Make Firefox run in Wayland native mode
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
