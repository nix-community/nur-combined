{ pkgs, ... }: {
  imports = [
    ./desktop.nix
    ../hardware/halo65.nix
  ];

  abszero = {
    virtualisation.libvirtd.enable = true;
    services = {
      kanata.enable = true;
      act.enable = true;
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

  # For obsidian
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  virtualisation.waydroid.enable = true;

  services = {
    gnome.gnome-keyring.enable = true; # For storing vscode auth token
    mpd.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
      desktopManager.plasma5.enable = true;
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
    systemPackages =
      with pkgs;
      with libsForQt5;
      [
        # TODO: Switch to anki-qt6 when it is no longer broken on Wayland
        anki-bin-qt6
        aseprite
        clinfo # For Plasma Info Center
        ffmpeg_5-full
        gh
        git-absorb
        git-secret
        glxinfo # For Plasma Info Center
        gnome-solanum
        goldendict-ng
        inkscape
        jetbrains.idea-community
        jq
        katawa-shoujo
        kooha
        libreoffice-qt
        neofetch
        noita_save_manager
        obsidian-ime
        pciutils # For Plasma Info Center
        protonmail-bridge
        protonvpn-gui
        qtstyleplugin-kvantum # For Colloid-kde
        sddm-kcm # SDDM Plasma integration
        taisei
        tenacity
        unzip
        (ventoy-bin.override {
          defaultGuiType = "qt5";
          withQt5 = true;
        })
        vesktop
        vscode
        vulkan-tools # For Plasma Info Center
        wayland-utils # For Plasma Info Center
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
