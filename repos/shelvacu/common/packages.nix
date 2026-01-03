{
  pkgs,
  config,
  lib,
  vacuModuleType,
  ...
}:
let
  enableFfmpeg = !config.vacu.isMinimal;
  enableFfmpegFull = enableFfmpeg && config.vacu.isGui;
  enableFfmpegHeadless = enableFfmpeg && !config.vacu.isGui;
  winePkgs = pkgs.wineWow64Packages;
in
{
  vacu.packages = lib.mkMerge [
    {
      sanoid.enable = lib.mkIf (
        vacuModuleType == "nixos" && config.boot.supportedFilesystems.zfs or false
      ) true;
      borgbackup.enable = config.vacu.isDev && (pkgs.stdenv.hostPlatform.system != "aarch64-linux"); # borgbackup build is borken on aarch64
      ffmpeg-vacu-full = {
        enable = enableFfmpegFull;
        package = pkgs.ffmpeg-full;
        overrides.libbluray = config.vacu.packages.libbluray-all.finalPackage;
      };
      ffmpeg-vacu-headless = {
        enable = enableFfmpegHeadless;
        package = pkgs.ffmpeg-headless;
        overrides.libbluray = config.vacu.packages.libbluray-all.finalPackage;
      };
      libbluray-all = {
        package = pkgs.libbluray;
        overrides = {
          withJava = true;
          withAACS = true;
          withBDplus = true;
        };
      };
      inkscape-all = {
        enable = false;
        package = pkgs.inkscape-with-extensions;
        # null actually means everything https://github.com/NixOS/nixpkgs/commit/5efd65b2d94b0ac0cf155e013b6747fa22bc04c3
        overrides.inkscapeExtensions = null;
      };
      p7zip-unfree = {
        package = pkgs.p7zip;
        overrides.enableUnfree = true;
      };
      ruby.package = lib.mkOverride 900 pkgs.ruby_3_4;
      wine.package = winePkgs.waylandFull;
      wine-fonts.package = winePkgs.fonts;
      vacu-units.package = config.vacu.units.finalPackage;
    }
    {
      tshark.enable = !config.vacu.isMinimal && !config.vacu.isGui;
      wireshark.enable = !config.vacu.isMinimal && config.vacu.isGui;
    }
    (lib.mkIf config.vacu.isGui
      # just do all the matrix clients, surely one of them will work enough
      ''
        # keep-sorted start
        # cinny-desktop # marked broken
        element-call
        element-desktop
        fluffychat
        fractal
        gomuks
        gomuks-web
        # hydrogen has no -desktop version
        iamb
        kazv
        matrix-commander
        matrix-commander-rs
        matrix-dl
        mm
        neosay
        nheko
        pinecone
        # quaternion # build is borked
        # keep-sorted end
      ''
    )
    (lib.mkIf config.vacu.isGui
      # pkgs for systems with a desktop GUI
      ''
        # keep-sorted start
        acpi
        anki
        arduino-ide
        audacity
        bitwarden-desktop
        brave
        dino
        filezilla
        gamemode
        ghidra
        gimp
        gnome-maps
        gparted
        haruna
        iio-sensor-proxy
        inkscape
        josm
        kdePackages.elisa
        kdePackages.kdenlive
        libreoffice-qt6-fresh
        merkaartor
        monero-gui
        obsidian
        openscad
        openterface-qt
        orca-slicer
        oscar
        prismlauncher
        shotcut
        signal-desktop
        simplex-chat-desktop
        svp
        tor-browser
        tremotesf
        ungoogled-chromium
        vlc
        wayland-utils
        wev
        wine
        wine-fonts
        wl-clipboard
        xev
        # keep-sorted end
      ''
    )
    # pkgs for development-ish
    (lib.mkIf config.vacu.isDev ''
      # keep-sorted start
      cargo
      clippy
      gdb
      gnumake
      man-pages
      nixpkgs-review
      patchelf
      python3
      ruby
      rust-script
      rustc
      shellcheck
      stdenv.cc
      # keep-sorted end
    '')
    (lib.mkIf (config.vacu.isGui)
      # pkgs useful for debugging input/events/evdev
      ''
        evtest
        evtest-qt
        evhz
      ''
    )
    (lib.mkIf (!config.vacu.isMinimal)
      # big pkgs for non-minimal systems
      ''
        # keep-sorted start
        aircrack-ng
        android-tools
        bitwarden-cli
        dmidecode
        flac
        gh
        hdparm
        home-manager
        imagemagickBig
        kanidm_1_8
        libfido2
        libsmi
        man
        mbuffer
        mdadm
        megatools
        mercurial #aka hg
        minicom
        mkvtoolnix-cli
        net-snmp
        nix-index
        nix-inspect
        nix-search-cli
        nix-tree
        nmap
        nvme-cli
        proxmark3
        rclone
        ripgrep-all
        show-pd-power
        smartmontools
        sqlite-interactive
        sshpass
        tcpdump
        termscp
        vrb
        yt-dlp
        # keep-sorted end
      ''
    )
    # pkgs included everywhere
    ''
      # keep-sorted start
      _7zip
      altcaps
      ddrescue
      dnsutils
      ethtool
      file
      gnutls
      gptfdisk
      hostname
      htop
      inetutils
      iperf3
      iputils
      jq
      jujutsu
      killall
      libossp_uuid # provides `uuid` binary
      linuxquota
      lshw
      lsof
      mosh
      nano
      ncdu
      netcat-openbsd
      nixos-rebuild
      openssl
      # p7zip-unfree
      pciutils
      progress
      psmisc
      psutils
      pv
      ripgrep
      rsync
      screen
      # sed => gnused
      shellvaculib
      ssh-to-age
      sshfs
      tmux
      tree
      tzdata
      unixtools.netstat
      unzip
      usbutils
      vacu-units
      vim
      wget
      xq-xml # like `jq` but for xml
      zip
      # keep-sorted end
    ''
    # packages that are in [`requiredPackages`][1]  in nixos, but maybe not included in nix-on-droid
    # [1]: https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/modules/config/system-path.nix#L11
    (lib.optionalAttrs (vacuModuleType == "nix-on-droid") ''
      #stdenv.cc.libc shouldn't be needed right?
      # keep-sorted start
      acl
      attr
      bashInteractive
      bzip2
      cpio
      curl
      diffutils
      findutils
      gawk
      getconf
      getent
      gnugrep
      gnupatch
      gnused
      gnutar
      gzip
      less
      libcap
      mkpasswd
      ncurses
      openssh
      procps
      su
      time
      util-linux
      which
      xz
      zstd
      # keep-sorted end
    '')
  ];
}
