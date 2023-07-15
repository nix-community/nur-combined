{ pkgs, ... }:

{
  sane.programs = {
    # PACKAGE SETS
    sysadminUtils = {
      package = null;
      suggestedPrograms = [
        "btrfs-progs"
        "cacert.unbundled"  # some services require unbundled /etc/ssl/certs
        "cryptsetup"
        "dig"
        "efibootmgr"
        "fatresize"
        "fd"
        "file"
        "gawk"
        "git"
        "gptfdisk"
        "hdparm"
        "htop"
        "iftop"
        "inetutils"  # for telnet
        "iotop"
        "iptables"
        "jq"
        "killall"
        "lsof"
        "miniupnpc"
        "nano"
        #  "ncdu"  # ncurses disk usage. doesn't cross compile (zig)
        "neovim"
        "netcat"
        "nethogs"
        "nmap"
        "openssl"
        "parted"
        "pciutils"
        "powertop"
        "pstree"
        "ripgrep"
        "screen"
        "smartmontools"
        "socat"
        "strace"
        "subversion"
        "tcpdump"
        "tree"
        "usbutils"
        "wget"
        "wirelesstools"  # iwlist
      ];
    };
    sysadminExtraUtils = {
      package = null;
      suggestedPrograms = [
        "backblaze-b2"
        "duplicity"
        "sqlite"  # to debug sqlite3 databases
      ];
    };

    # TODO: split these into smaller groups.
    # - moby doesn't want a lot of these.
    # - categories like
    #   - dev?
    #   - debugging?
    consoleUtils = {
      package = null;
      suggestedPrograms = [
        "alsaUtils"  # for aplay, speaker-test
        # "cdrtools"
        "clinfo"
        "dmidecode"
        "efivar"
        # "flashrom"
        "fwupd"
        "gh"  # MS GitHub cli
        "git"  # needed as a user package, for config.
        # "gnupg"
        # "gocryptfs"
        # "gopass"
        # "gopass-jsonapi"
        "helix"  # text editor
        "kitty"  # TODO: move to GUI, but `ssh servo` from kitty sets `TERM=xterm-kitty` in the remove and breaks things
        "libsecret"  # for managing user keyrings. TODO: what needs this? lift into the consumer
        "lm_sensors"  # for sensors-detect. TODO: what needs this? lift into the consumer
        "lshw"
        # "memtester"
        "neovim"  # needed as a user package, for swap persistence
        # "nettools"
        # "networkmanager"
        "nix-index"
        "nixpkgs-review"
        # "nixos-generators"
        "nmon"
        # "node2nix"
        # "oathToolkit"  # for oathtool
        # "ponymix"
        "pulsemixer"
        "python3"
        # "python3Packages.eyeD3"  # music tagging
        "ripgrep"  # needed as a user package so that its user-level config file can be installed
        "rsync"
        "sane-scripts"
        "sequoia"
        "snapper"
        "sops"
        "speedtest-cli"
        # "ssh-to-age"
        "sudo"
        # "tageditor"  # music tagging
        "unar"
        "wireguard-tools"
        "xdg-terminal-exec"
        "xdg-utils"  # for xdg-open
        # "yarn"
        "zsh"
      ];
    };

    consoleMediaUtils = {
      package = null;
      suggestedPrograms = [
        "ffmpeg"
        "imagemagick"
        "sox"
        "yt-dlp"
      ];
    };

    tuiApps = {
      package = null;
      suggestedPrograms = [
        "aerc"  # email client
        "msmtp"  # sendmail
        "offlineimap"  # email mailox sync
        "sfeed"  # RSS fetcher
        "visidata"  # TUI spreadsheet viewer/editor
        "w3m"  # web browser
      ];
    };

    iphoneUtils = {
      package = null;
      suggestedPrograms = [
        "ifuse"
        "ipfs"
        "libimobiledevice"
      ];
    };

    devPkgs = {
      package = null;
      suggestedPrograms = [
        "clang"
        "nodejs"
        "tree-sitter"
      ];
    };


    # INDIVIDUAL PACKAGE DEFINITIONS

    dino.persist.private = [ ".local/share/dino" ];

    # creds, but also 200 MB of node modules, etc
    discord.persist.private = [ ".config/discord" ];

    # creds/session keys, etc
    element-desktop.persist.private = [ ".config/Element" ];

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.plaintext = [ ".local/share/Emote" ];

    fluffychat-moby.persist.plaintext = [ ".local/share/chat.fluffy.fluffychat" ];

    # XXX by default fractal stores its state in ~/.local/share/<UUID>.
    # after logging in, manually change ~/.local/share/keyrings/... to point it to some predictable subdir.
    # then reboot (so that libsecret daemon re-loads the keyring...?)
    fractal-latest.persist.private = [ ".local/share/fractal" ];
    fractal-next.persist.private = [ ".local/share/fractal" ];

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

    # hardenedMalloc solves an "unable to connect to Tor" error when pressing the "connect" button
    # - still required as of 2023/07/14
    tor-browser-bundle-bin.package = pkgs.tor-browser-bundle-bin.override {
      useHardenedMalloc = false;
    };

    whalebird.persist.private = [ ".config/Whalebird" ];

    yarn.persist.plaintext = [ ".cache/yarn" ];

    # zcash coins. safe to delete, just slow to regenerate (10-60 minutes)
    zecwallet-lite.persist.private = [ ".zcash" ];
  };
}
