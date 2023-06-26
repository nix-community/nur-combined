{ lib, pkgs, ... }:

let
  inherit (builtins) attrNames;

  flattenedPkgs = pkgs // (with pkgs; {
    # XXX can't `inherit` a nested attr, so we move them to the toplevel
    "cacert.unbundled" = pkgs.cacert.unbundled;
    "gnome.cheese" = gnome.cheese;
    "gnome.dconf-editor" = gnome.dconf-editor;
    "gnome.file-roller" = gnome.file-roller;
    "gnome.gnome-disk-utility" = gnome.gnome-disk-utility;
    "gnome.gnome-maps" = gnome.gnome-maps;
    "gnome.nautilus" = gnome.nautilus;
    "gnome.gnome-system-monitor" = gnome.gnome-system-monitor;
    "gnome.gnome-terminal" = gnome.gnome-terminal;
    "gnome.gnome-weather" = gnome.gnome-weather;
    "gnome.totem" = gnome.totem;
    "libsForQt5.plasmatube" = libsForQt5.plasmatube;
  });

  sysadminPkgs = {
    inherit (flattenedPkgs)
      btrfs-progs
      "cacert.unbundled"  # some services require unbundled /etc/ssl/certs
      cryptsetup
      dig
      efibootmgr
      fatresize
      fd
      file
      gawk
      git
      gptfdisk
      hdparm
      htop
      iftop
      inetutils  # for telnet
      iotop
      iptables
      jq
      killall
      lsof
      miniupnpc
      nano
      netcat
      nethogs
      nmap
      openssl
      parted
      pciutils
      powertop
      pstree
      ripgrep
      screen
      smartmontools
      socat
      strace
      subversion
      tcpdump
      tree
      usbutils
      wget
      wirelesstools  # iwlist
    ;
  };
  sysadminExtraPkgs = {
    # application-specific packages
    inherit (pkgs)
      backblaze-b2
      duplicity
      sqlite  # to debug sqlite3 databases
    ;
  };

  iphonePkgs = {
    inherit (pkgs)
      ifuse
      ipfs
      libimobiledevice
    ;
  };

  tuiPkgs = {
    inherit (pkgs)
      aerc  # email client
      offlineimap  # email mailox sync
      sfeed  # RSS fetcher
      visidata  # TUI spreadsheet viewer/editor
      w3m
    ;
  };

  consoleMediaPkgs = {
    inherit (pkgs)
      ffmpeg
      imagemagick
      sox
      yt-dlp
    ;
  };
  # TODO: split these into smaller groups.
  # - moby doesn't want a lot of these.
  # - categories like
  #   - dev?
  #   - debugging?
  consolePkgs = {
    inherit (pkgs)
      alsaUtils  # for aplay, speaker-test
      # cdrtools
      clinfo
      dmidecode
      efivar
      # flashrom
      fwupd
      gh  # MS GitHub cli
      git  # needed as a user package, for config.
      # gnupg
      # gocryptfs
      # gopass
      # gopass-jsonapi
      kitty  # TODO: move to GUI, but `ssh servo` from kitty sets `TERM=xterm-kitty` in the remove and breaks things
      libsecret  # for managing user keyrings. TODO: what needs this? lift into the consumer
      lm_sensors  # for sensors-detect. TODO: what needs this? lift into the consumer
      lshw
      # memtester
      neovim
      # nettools
      # networkmanager
      nixpkgs-review
      # nixos-generators
      nmon
      # node2nix
      # oathToolkit  # for oathtool
      # ponymix
      pulsemixer
      python3
      ripgrep  # needed as a user package so that its user-level config file can be installed
      rsync
      # python3Packages.eyeD3  # music tagging
      sane-scripts
      sequoia
      snapper
      sops
      speedtest-cli
      # ssh-to-age
      sudo
      # tageditor  # music tagging
      unar
      wireguard-tools
      xdg-utils  # for xdg-open
      # yarn
      zsh
    ;
  };

  guiPkgs = {
    inherit (flattenedPkgs)
      # celluloid  # mpv frontend
      cozy  # audiobook player
      # emote
      evince  # works on phosh

      # { pkg = fluffychat-moby; persist.plaintext = [ ".local/share/chat.fluffy.fluffychat" ]; }  # TODO: ship normal fluffychat on non-moby?

      # foliate  # e-book reader

      # XXX by default fractal stores its state in ~/.local/share/<UUID>.
      # after logging in, manually change ~/.local/share/keyrings/... to point it to some predictable subdir.
      # then reboot (so that libsecret daemon re-loads the keyring...?)
      # { pkg = fractal-latest; persist.private = [ ".local/share/fractal" ]; }
      # { pkg = fractal-next; persist.private = [ ".local/share/fractal" ]; }

      # "gnome.cheese"
      # gnome-feeds  # RSS reader (with claimed mobile support)
      "gnome.file-roller"
      # "gnome.gnome-maps"  # works on phosh
      "gnome.nautilus"
      # gnome-podcasts
      # "gnome.gnome-system-monitor"
      # "gnome.gnome-terminal"  # works on phosh
      # "gnome.gnome-weather"
      gpodder
      gthumb
      jellyfin-media-player
      komikku
      koreader
      # lollypop
      mepo  # maps viewer
      # mpv
      # networkmanagerapplet
      # newsflash
      nheko
      pavucontrol
      # picard  # music tagging
      # "libsForQt5.plasmatube"  # Youtube player
      soundconverter
      # sublime-music
      # tdesktop  # broken on phosh
      # tokodon
      tuba  # mastodon/pleroma client (stores pw in keyring)
      vlc
      # pleroma client (Electron). input is broken on phosh. TODO(2023/02/02): fix electron19 input (insecure)
      # whalebird
      xterm  # broken on phosh
    ;
  };
  desktopGuiPkgs = {
    inherit (flattenedPkgs)
      audacity
      brave  # for the integrated wallet -- as a backup
      chromium
      dino
      electrum
      element-desktop
      font-manager
      gajim  # XMPP client
      gimp  # broken on phosh
      "gnome.dconf-editor"
      "gnome.gnome-disk-utility"
      # "gnome.totem"  # video player, supposedly supports UPnP
      handbrake
      hase
      inkscape
      kdenlive
      kid3  # audio tagging
      krita
      libreoffice-fresh
      mumble
      obsidian
      slic3r
      steam
      wireshark  # could maybe ship the cli as sysadmin pkg
    ;
  };
  x86GuiPkgs = {
    inherit (pkgs)
      discord

      # kaiteki  # Pleroma client
      # gnome.zenity # for kaiteki (it will use qarma, kdialog, or zenity)
      # gpt2tc  # XXX: unreliable mirror

      # logseq  # Personal Knowledge Management
      losslesscut-bin
      makemkv
      monero-gui
      signal-desktop
      spotify
      tor-browser-bundle-bin
      zecwallet-lite
    ;
  };

  # packages not part of any package set; not enabled by default
  otherPkgs = {
    inherit (pkgs)
      lemmy-server
      mx-sanebot
      stepmania
    ;
  };

  # define -- but don't enable -- the packages in some attrset.
  declarePkgs = pkgsAsAttrs: lib.mapAttrs (_n: p: {
    # no need to actually define the package here: it's defaulted
    # package = mkDefault p;
  }) pkgsAsAttrs;
in
{
  sane.programs = lib.mkMerge [
    (declarePkgs consoleMediaPkgs)
    (declarePkgs consolePkgs)
    (declarePkgs desktopGuiPkgs)
    (declarePkgs guiPkgs)
    (declarePkgs iphonePkgs)
    (declarePkgs sysadminPkgs)
    (declarePkgs sysadminExtraPkgs)
    (declarePkgs tuiPkgs)
    (declarePkgs x86GuiPkgs)
    (declarePkgs otherPkgs)
    {
      # link the various package sets into their own meta packages
      consoleMediaUtils = {
        package = null;
        suggestedPrograms = attrNames consoleMediaPkgs;
      };
      consoleUtils = {
        package = null;
        suggestedPrograms = attrNames consolePkgs;
      };
      desktopGuiApps = {
        package = null;
        suggestedPrograms = attrNames desktopGuiPkgs;
      };
      guiApps = {
        package = null;
        suggestedPrograms = (attrNames guiPkgs)
          ++ [ "web-browser" ]
          ++ [ "tuiApps" ]
          ++ lib.optional (pkgs.system == "x86_64-linux") "x86GuiApps";
      };
      iphoneUtils = {
        package = null;
        suggestedPrograms = attrNames iphonePkgs;
      };
      sysadminUtils = {
        package = null;
        suggestedPrograms = attrNames sysadminPkgs;
      };
      sysadminExtraUtils = {
        package = null;
        suggestedPrograms = attrNames sysadminExtraPkgs;
      };
      tuiApps = {
        package = null;
        suggestedPrograms = attrNames tuiPkgs;
      };
      x86GuiApps = {
        package = null;
        suggestedPrograms = attrNames x86GuiPkgs;
      };
    }
    {
      # nontrivial package definitions

      dino.persist.private = [ ".local/share/dino" ];

      # creds, but also 200 MB of node modules, etc
      discord.persist.private = [ ".config/discord" ];

      # creds/session keys, etc
      element-desktop.persist.private = [ ".config/Element" ];

      # `emote` will show a first-run dialog based on what's in this directory.
      # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
      # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
      emote.persist.plaintext = [ ".local/share/Emote" ];

      # MS GitHub stores auth token in .config
      # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
      gh.persist.private = [ ".config/gh" ];

      # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
      # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
      monero-gui.persist.plaintext = [ ".bitmonero" ];

      mumble.persist.private = [ ".local/share/Mumble" ];

      # not strictly necessary, but allows caching articles; offline use, etc.
      nheko.persist.private = [
        ".config/nheko"  # config file (including client token)
        ".cache/nheko"  # media cache
        ".local/share/nheko"  # per-account state database
      ];

      # settings (electron app)
      obsidian.persist.plaintext = [ ".config/obsidian" ];

      # creds, media
      signal-desktop.persist.private = [ ".config/Signal" ];

      # printer/filament settings
      slic3r.persist.plaintext = [ ".Slic3r" ];

      # creds, widevine .so download. TODO: could easily manage these statically.
      spotify.persist.plaintext = [ ".config/spotify" ];

      tdesktop.persist.private = [ ".local/share/TelegramDesktop" ];

      tokodon.persist.private = [ ".cache/KDE/tokodon" ];

      # hardenedMalloc solves a crash at startup
      # TODO 2023/02/02: is this safe to remove yet?
      tor-browser-bundle-bin.package = pkgs.tor-browser-bundle-bin.override {
        useHardenedMalloc = false;
      };

      whalebird.persist.private = [ ".config/Whalebird" ];

      yarn.persist.plaintext = [ ".cache/yarn" ];

      # zcash coins. safe to delete, just slow to regenerate (10-60 minutes)
      zecwallet-lite.persist.private = [ ".zcash" ];
    }
  ];
}
