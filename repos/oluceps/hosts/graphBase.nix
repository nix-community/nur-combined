{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:
{
  xdg = {
    mime = {
      enable = true;
      inherit
        ((import ../home/graphBase.nix {
          inherit
            config
            pkgs
            lib
            inputs
            user
            ;
        }).xdg.mimeApps
        )
        defaultApplications
        ;
    };
    portal.wlr.enable = true;
    portal.enable = true;
  };
  programs = {
    dconf.enable = true;
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    # niri.enable = true;
    sway.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    kdeconnect.enable = true;
    adb.enable = true;
    command-not-found.enable = false;
    steam = {
      enable = true;
      package = pkgs.steam.override { extraPkgs = pkgs: [ pkgs.maple-mono-SC-NF ]; };
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    gnupg = {
      agent = {
        enable = false;
        pinentryPackage = pkgs.pinentry-curses;
        enableSSHSupport = true;
      };
    };
  };
  environment.systemPackages = lib.flatten (
    lib.attrValues (
      with pkgs;
      {
        crypt = [
          minisign
          rage
          age-plugin-yubikey
          cryptsetup
          tpm2-tss
          tpm2-tools
          yubikey-manager
          yubikey-manager-qt
          monero-cli
        ];

        # python = [ (python311.withPackages (ps: with ps; [ pandas requests absl-py tldextract bleak matplotlib clang ])) ];

        lang = [
          [
            editorconfig-checker
            kotlin-language-server
            sumneko-lua-language-server
            yaml-language-server
            tree-sitter
            stylua
            biome
            # black
          ]
          # languages related
          [
            zig
            lldb
            # haskell-language-server
            gopls
            cmake-language-server
            zls
            android-file-transfer
            nixpkgs-review
            shfmt
          ]
        ];
        wine = [
          # bottles
          wineWowPackages.stable

          # support 32-bit only
          # wine

          # support 64-bit only
          (wine.override { wineBuild = "wine64"; })

          # wine-staging (version with experimental features)
          wineWowPackages.staging

          # winetricks (all versions)
          winetricks

          # native wayland support (unstable)
          wineWowPackages.waylandFull
        ];
        dev = [
          friture
          qemu-utils
          yubikey-personalization
          racket
          resign
          pv
          devenv
          gnome.dconf-editor
          [
            swagger-codegen3
            bump2version
            openssl
            linuxPackages_latest.perf
            cloud-utils
          ]
          [
            bpf-linker
            gdb
            gcc
            gnumake
            cmake
          ] # clang-tools_15 llvmPackages_latest.clang ]
          # [ openocd ]
          lua
          delta
          # nodejs-18_x
          switch-mute
          go

          nix-tree
          kotlin
          jre17_minimal
          inotify-tools
          rustup
          tmux
          # awscli2

          trunk
          cargo-expand
          wasmer
          wasmtime
          comma
          nix-update
          nodejs_latest.pkgs.pnpm
        ];
        db = [ mongosh ];

        web = [ hugo ];

        de = with gnomeExtensions; [
          simple-net-speed
          paperwm
        ];

        virt = [
          # virt-manager
          virtiofsd
          runwin
          guix-run
          runbkworm
          bkworm
          arch-run
          # ubt-rv-run
          #opulr-a-run
          lunar-run
          virt-viewer
        ];
        fs = [
          gparted
          e2fsprogs
          fscrypt-experimental
          f2fs-tools
          compsize
        ];

        cmd = [
          metasploit
          # linuxKernel.packages.linux_latest_libre.cpupower
          clean-home
          just
          typst
          cosmic-term
          acpi
        ];
        bluetooth = [ bluetuith ];

        sound = [ pulseaudio ];

        display = [ cage ];
      }
    )
  );
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
    platformTheme = "gnome";
    style = "adwaita";
  };
  security = {
    pam.services.swaylock = { };
    # Enable sound.
    rtkit.enable = true;
  };
  services = {

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.writeShellScript "sway" ''
            export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
            exec sway
          ''}";
          inherit user;
        };
        default_session = initial_session;
      };
    };

    acpid.enable = true;
    udev = {
      packages = with pkgs; [
        android-udev-rules
        # qmk-udev-rules
        jlink-udev-rules
        yubikey-personalization
        libu2f-host
        via
        opensk-udev-rules
        nrf-udev-rules
      ];
    };
    gnome.gnome-keyring.enable = true;

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

        (nerdfonts.override {
          fonts = [
            "FiraCode"
            "JetBrainsMono"
            "FantasqueSansMono"
          ];
        })
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
      ++ (with pkgs.glowsans; [
        glowsansSC
        glowsansTC
        glowsansJ
      ])
      ++ (with pkgs; [
        san-francisco
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
        ];
        monospace = [
          "Monaspace Neon"
          "Maple Mono"
          "SF Mono"
          "Fantasque Sans Mono"
        ];
        sansSerif = [
          "Hanken Grotesk"
          "Glow Sans SC"
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
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
        fcitx5-pinyin-zhwiki
        fcitx5-pinyin-moegirl
      ];
    };
  };
}
