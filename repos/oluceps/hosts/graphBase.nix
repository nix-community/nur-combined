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
    [
      google-chrome-beta # Beta Release

      (pkgs.runCommand "chrome-entry" { } ''
        mkdir -p $out/share/applications/
        echo "[Desktop Entry]
              Version=1.0
              Name=Google Chrome
              # Only KDE 4 seems to use GenericName, so we reuse the KDE strings.
              # From Ubuntu's language-pack-kde-XX-base packages, version 9.04-20090413.
              GenericName=Web Browser
              GenericName[en_GB]=Web Browser
              GenericName[zh_CN]=网页浏览器
              Comment[zh_CN]=访问互联网
              Exec=${lib.getExe google-chrome-beta} --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 --video-capture-use-gpu-memory-buffer --force-color-profile=display-p3-d65 --enable-zero-copy --enable-features=CanvasOopRasterization,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiVideoEncoder,ScrollableTabStrip,OverlayScrollbar %U
              # Exec=${lib.getExe google-chrome-beta} --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 --video-capture-use-gpu-memory-buffer --force-color-profile=display-p3-d65 --use-gl=angle --use-angle=vulkan --enable-zero-copy --enable-features=CanvasOopRasterization,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiVideoEncoder,ScrollableTabStrip,OverlayScrollbar %U
              StartupNotify=true
              Terminal=false
              Icon=google-chrome
              Type=Application
              Categories=Network;WebBrowser;
              MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
              Actions=new-window;new-private-window;" > $out/share/applications/google-chrome-dev.desktop'')

    ]
    ++ [
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
        ];
      })
      pkgs.systemd-run-app
    ];
  xdg = {
    mime = {
      enable = true;
      defaultApplications =
        {
          "application/x-xdg-protocol-tg" = [ "org.telegram.desktop.desktop" ];
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
          "application/pdf" = [ "sioyek.desktop" ];
          "ppt/pptx" = [ "wps-office-wpp.desktop" ];
          "doc/docx" = [ "wps-office-wps.desktop" ];
          "xls/xlsx" = [ "wps-office-et.desktop" ];
        }
        //
          lib.genAttrs
            [
              "x-scheme-handler/unknown"
              "x-scheme-handler/about"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/mailto"
              "text/html"
            ]
            # (_: "brave-browser.desktop")
            (_: "google-chrome-dev.desktop")
        // lib.genAttrs [
          "image/gif"
          "image/webp"
          "image/png"
          "image/jpeg"
        ] (_: "org.gnome.Loupe.desktop")
        // lib.genAttrs [
          "inode/directory"
          "inode/mount-point"
        ] (_: "org.gnome.Nautilus.desktop");
    };
    portal = {
      enable = true;
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
          pkgs.maple-mono-SC-NF
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
        enableSSHSupport = true;
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
        # {
        #   timeout = 900;
        #   command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
        # }
        {
          timeout = 901;
          command = "/run/current-system/systemd/bin/loginctl lock-session";
        }
      ];
      events = [
        {
          event = "lock";
          # command = "${pkgs.hyprlock}/bin/hyprlock --immediate";
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
      extraRules = ''
        ACTION=="remove",\
         ENV{ID_BUS}=="usb",\
         ENV{ID_MODEL_ID}=="0407",\
         ENV{ID_VENDOR_ID}=="1050",\
         ENV{ID_VENDOR}=="Yubico",\
         RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      '';
      packages = with pkgs; [
        android-udev-rules
        # qmk-udev-rules
        jlink-udev-rules
        yubikey-personalization
        nitrokey-udev-rules
        libu2f-host
        via
        # opensk-udev-rules
        nrf-udev-rules
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
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        source-han-sans
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        twemoji-color-font
        maple-mono-SC-NF
        maple-mono-otf
        maple-mono-autohint
        cascadia-code
        intel-one-mono
        monaspace
      ]
      ++ (with pkgs; [
        glowsans-j
        glowsans-tc
        glowsans-sc
      ])
      ++ (with pkgs; [
        plangothic
        maoken-tangyuan
        lxgw-neo-xihei
      ]);
    #"HarmonyOS Sans SC" "HarmonyOS Sans TC"
    fontconfig = {
      subpixel.rgba = "none";
      antialias = true;
      hinting.enable = false;
      defaultFonts = lib.mkForce {
        serif = [
          "Glow Sans SC"
          "Glow Sans TC"
          "Glow Sans J"
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "LXGW Neo XiHei"
        ];
        monospace = [
          "Monaspace Neon"
          "Maple Mono"
        ];
        sansSerif = [
          "Hanken Grotesk"
          "Glow Sans SC"
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
        plasma6Support = true;
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-mozc
          fcitx5-rime
          fcitx5-gtk
          fcitx5-configtool
          fcitx5-pinyin-zhwiki
          fcitx5-pinyin-moegirl
        ];
      };
    };
  };
}
