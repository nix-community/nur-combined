{
  config,
  pkgs,
  lib,
  inputs',
  ...
}:
{
  imports = [ ./niri.nix ];
  environment.systemPackages =
    with inputs'.browser-previews.packages;
    (
      let
        chromium = pkgs.chromium.override {
          commandLineArgs = [
            "--video-capture-use-gpu-memory-buffer"
            "--force-color-profile=display-p3-d65"
            "--use-gl=angle"
            "--use-angle=vulkan"
            "--enable-zero-copy"
            "--ignore-gpu-blocklist"
            "--enable-features=${
              lib.concatStringsSep "," [
                "OverlayScrollbar"
                "ParallelDownloading"
                "MiddleClickAutoscroll"
                "CanvasOopRasterization"
                "AcceleratedVideoDecoder"
                "AcceleratedVideoDecodeLinuxZeroCopyGL"
                "AcceleratedVideoEncoder"
                "VaapiIgnoreDriverChecks"
                "Vulkan"
                "VulkanFromANGLE"
                "DefaultANGLEVulkan"
              ]
            }"
            "--ozone-platform-hint=auto"
            "--enable-wayland-ime"
            "--wayland-text-input-version=3"
            "--disk-cache-dir=\"$XDG_RUNTIME_DIR/chromium-cache\""
            "--oauth2-client-id=77185425430.apps.googleusercontent.com"
            "--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT"
            "--user-data-dir=\"$\{XDG_CONFIG_HOME:-$\{HOME}/.config}/chromium-sync\""
          ];
          enableWideVine = true;
        };
      in
      [
        chromium
      ]
    )
    ++ [
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
        ];
      })
      pkgs.systemd-run-app
      pkgs.wechat
      pkgs.porsmo
    ];
  xdg = {
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "foot.desktop" ];
      };
    };
    mime = {
      enable = true;
      defaultApplications = {
        "application/x-xdg-protocol-tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "application/pdf" = [ "sioyek.desktop" ];
        "ppt/pptx" = [ "wps-office-wpp.desktop" ];
        "doc/docx" = [ "wps-office-wps.desktop" ];
        "xls/xlsx" = [ "wps-office-et.desktop" ];
        "application/epub+zip" = [ "com.github.johnfactotum.Foliate.desktop" ];
        "x-scheme-handler/terminal" = [ "foot.desktop" ];
      }
      // lib.genAttrs [
        "x-scheme-handler/unknown"
        "x-scheme-handler/about"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/mailto"
        "text/html"
      ] (_: "chromium-browser.desktop")
      // lib.genAttrs [
        "image/gif"
        "image/webp"
        "image/png"
        "image/jpeg"
        "image/bmp"
        "image/svg+xml"
      ] (_: "org.gnome.Loupe.desktop")
      // lib.genAttrs [
        "inode/directory"
        "inode/mount-point"
      ] (_: "org.gnome.Nautilus.desktop")
      // lib.genAttrs [
        "text/plain"
        "application/toml"
        "application/json"
        "text/css"
        "text/csv"

      ] (_: "Helix.desktop");
    };
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      configPackages = [ pkgs.niri ];
    };
  };

  programs = {
    dconf.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    kdeconnect.enable = false;
    adb.enable = true;
    command-not-found.enable = false;
    gamescope.enable = true;
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [
          pkgs.maple-mono.NF-CN-unhinted
          pkgs.gamescope
          pkgs.mangohud
        ];
      };
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;
    };
    firefox = {
      enable = true;
      package =
        (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped
          { };
    };
    gnupg = {
      agent = {
        enable = false;
        pinentryPackage = pkgs.wayprompt;
        # enableSSHSupport = true;
      };
    };
  };
  virtualisation = {
    libvirtd = {
      enable = false;
      qemu.ovmf = {
        enable = true;
        packages =
          # let
          #   pkgs = import inputs.nixpkgs-22 {
          #     system = "x86_64-linux";
          #   };
          # in
          [
            pkgs.OVMFFull.fd
            pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
      };
      qemu.swtpm.enable = true;
    };
    waydroid.enable = false;
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita";
  };
  security = {
    pam.services.swaylock = { };
    rtkit.enable = true;
  };
  services = {
    swayidle = {
      enable = true;
      systemdTarget = "niri.service";
      timeouts = [
        {
          timeout = 900;
          command = "/run/current-system/systemd/bin/loginctl lock-session";
        }
        {
          timeout = 915;
          command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
        }
      ];
      events = [
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock";
        }
        {
          event = "before-sleep";
          command = "/run/current-system/systemd/bin/loginctl lock-session";
        }
      ];
    };

    # desktopManager.cosmic.enable = true;
    # displayManager.cosmic-greeter.enable = true;

    acpid.enable = true;
    udev = {
      # Remove Yubikey Auto Lock
      # extraRules = ''
      #   ACTION=="remove",\
      #    ENV{ID_BUS}=="usb",\
      #    ENV{ID_MODEL_ID}=="0407",\
      #    ENV{ID_VENDOR_ID}=="1050",\
      #    ENV{ID_VENDOR}=="Yubico",\
      #    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      # '';
      packages = with pkgs; [
        android-udev-rules
        # qmk-udev-rules
        jlink-udev-rules
        yubikey-personalization
        nitrokey-udev-rules
        libu2f-host
        # via
        # opensk-udev-rules
        nrf-udev-rules
        disallow-generic-driver-for-switch-rules
      ];
    };
    # gnome.gnome-keyring.enable = true;

    flatpak.enable = true;
    pcscd.enable = true;
    xserver = {
      enable = lib.mkDefault false;
      xkb.layout = "us";
    };
  };

  systemd.user.services.nix-index = {
    environment = config.networking.proxy.envVars;
    script = ''
      FILE=index-x86_64-linux
      mkdir -p ~/.cache/nix-index
      cd ~/.cache/nix-index
      ${pkgs.curl}/bin/curl -LO https://github.com/Mic92/nix-index-database/releases/latest/download/$FILE
      mv -v $FILE files
    '';
    serviceConfig = {
      Restart = "on-failure";
      Type = "oneshot";
    };
    startAt = "weekly";
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    enableGhostscriptFonts = false;
    packages =
      with pkgs;
      [
        # nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        source-han-sans
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        twemoji-color-font
        maple-mono.NF-CN-unhinted
        # maple-mono.otf
        # maple-mono.autohint
        cascadia-code
        intel-one-mono
        monaspace
        stix-two
        fira-sans
      ]
      ++ (with pkgs; [
        plangothic
        maoken-tangyuan
        lxgw-neo-xihei
      ]);
    #"HarmonyOS Sans SC" "HarmonyOS Sans TC"
    fontconfig = {
      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };
      antialias = true;
      hinting.enable = false;
      defaultFonts = lib.mkForce {
        serif = [
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK HK"
          "LXGW Neo XiHei"
        ];
        monospace = [
          "Maple Mono NF CN"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans CJK HK"
          "Hanken Grotesk"
          "LXGW Neo XiHei"
        ];
        emoji = [
          "twemoji-color-font"
          "noto-fonts-emoji"
        ];
      };
    };
  };

  # $ nix search wget
  i18n = {

    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-rime
          (fcitx5-configtool.override { kcmSupport = false; })
        ];
      };
    };
  };
}
