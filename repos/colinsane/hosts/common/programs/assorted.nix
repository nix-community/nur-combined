{ config, lib, pkgs, ... }:

let
  declPackageSet = pkgs: {
    package = null;
    suggestedPrograms = pkgs;
  };
in
{
  sane.programs = {
    # PACKAGE SETS
    "sane-scripts.backup" = declPackageSet [
      "sane-scripts.backup-ls"
      "sane-scripts.backup-restore"
    ];
    "sane-scripts.bittorrent" = declPackageSet [
      "sane-scripts.bt-add"
      "sane-scripts.bt-rm"
      "sane-scripts.bt-search"
      "sane-scripts.bt-show"
    ];
    "sane-scripts.dev" = declPackageSet [
      "sane-scripts.clone"
      "sane-scripts.dev-cargo-loop"
      "sane-scripts.git-init"
    ];
    "sane-scripts.cli" = declPackageSet [
      "sane-scripts.deadlines"
      "sane-scripts.find-dotfiles"
      "sane-scripts.ip-check"
      "sane-scripts.ip-reconnect"
      "sane-scripts.private-change-passwd"
      "sane-scripts.private-do"
      "sane-scripts.private-init"
      "sane-scripts.private-lock"
      "sane-scripts.private-unlock"
      "sane-scripts.rcp"
      "sane-scripts.reboot"
      "sane-scripts.reclaim-boot-space"
      "sane-scripts.reclaim-disk-space"
      "sane-scripts.secrets-dump"
      "sane-scripts.secrets-unlock"
      "sane-scripts.secrets-update-keys"
      "sane-scripts.shutdown"
      "sane-scripts.sudo-redirect"
      "sane-scripts.sync-from-servo"
      "sane-scripts.tag-music"
      "sane-scripts.vpn"
      "sane-scripts.which"
      "sane-scripts.wipe"
    ];
    "sane-scripts.sys-utils" = declPackageSet [
      "sane-scripts.ip-port-forward"
      "sane-scripts.sync-music"
    ];


    sysadminUtils = declPackageSet [
      "btrfs-progs"
      "cacert.unbundled"  # some services require unbundled /etc/ssl/certs
      "cryptsetup"
      "ddrescue"
      "dig"
      "dtc"  # device tree [de]compiler
      "e2fsprogs"  # resize2fs
      "efibootmgr"
      "ethtool"
      "fatresize"
      "fd"
      "file"
      # "fwupd"
      "gawk"
      "gdb"  # to debug segfaults
      "git"
      "gptfdisk"  # gdisk
      "hdparm"
      "htop"
      "iftop"
      "inetutils"  # for telnet
      "iotop"
      "iptables"
      "iw"
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
      "nvme-cli"  # nvme
      "openssl"
      "parted"
      "pciutils"
      "powertop"
      "pstree"
      "ripgrep"
      "screen"
      "smartmontools"  # smartctl
      "socat"
      "strace"
      "subversion"
      "tcpdump"
      "tree"
      "usbutils"
      "util-linux"  # lsblk, lscpu, etc
      "wget"
      "wirelesstools"  # iwlist
      "xq"  # jq for XML
      # "zfs"  # doesn't cross-compile (requires samba)
    ];
    sysadminExtraUtils = declPackageSet [
      "backblaze-b2"
      "duplicity"
      "sane-scripts.backup"
      "sqlite"  # to debug sqlite3 databases
    ];

    # TODO: split these into smaller groups.
    # - moby doesn't want a lot of these.
    # - categories like
    #   - dev?
    #   - debugging?
    consoleUtils = declPackageSet [
      "alsaUtils"  # for aplay, speaker-test
      "binutils-unwrapped"  # for strings; though this brings 80MB of unrelated baggage too
      # "cdrtools"
      "clinfo"
      "dmidecode"
      "dtrx"  # `unar` alternative, "Do The Right eXtraction"
      "efivar"
      "eza"  # a better 'ls'
      # "flashrom"
      "git"  # needed as a user package, for config.
      # "gnupg"
      # "gocryptfs"
      # "gopass"
      # "gopass-jsonapi"
      "helix"  # text editor
      "libsecret"  # for managing user keyrings. TODO: what needs this? lift into the consumer
      "lm_sensors"  # for sensors-detect. TODO: what needs this? lift into the consumer
      "lshw"
      # "memtester"
      "mercurial"  # hg
      "mimeo"  # like xdg-open
      "neovim"  # needed as a user package, for swap persistence
      # "nettools"
      # "networkmanager"
      # "nixos-generators"
      "nmon"
      # "node2nix"
      # "oathToolkit"  # for oathtool
      # "ponymix"
      "pulsemixer"
      "python3-repl"
      # "python3Packages.eyeD3"  # music tagging
      "ripgrep"  # needed as a user package so that its user-level config file can be installed
      "rsync"
      "sane-scripts.bittorrent"
      "sane-scripts.cli"
      "snapper"
      "sops"
      "speedtest-cli"
      # "ssh-to-age"
      "sudo"
      # "tageditor"  # music tagging
      # "unar"
      "unzip"
      "wireguard-tools"
      "xdg-utils"  # for xdg-open
      # "yarn"
      "zsh"
    ];

    pcConsoleUtils = declPackageSet [
      "gh"  # MS GitHub cli
      "nix-index"
      "nixpkgs-review"
      "sane-scripts.dev"
      "sequoia"
    ];

    consoleMediaUtils = declPackageSet [
      "catt"  # cast videos to chromecast
      "ffmpeg"
      "go2tv"  # cast videos to UPNP/DLNA device (i.e. tv). TODO: needs firewall opened to allow sending of local files. (lappy sends a SSDP request to broadcast address, then gets response from concrete addr to the port it sent the req from).
      "imagemagick"
      "sox"
      "yt-dlp"
    ];

    pcTuiApps = declPackageSet [
      "aerc"  # email client
      "msmtp"  # sendmail
      "offlineimap"  # email mailbox sync
      # "sfeed"  # RSS fetcher
      "visidata"  # TUI spreadsheet viewer/editor
      "w3m"  # web browser
    ];

    iphoneUtils = declPackageSet [
      "ifuse"
      "ipfs"
      "libimobiledevice"
      "sane-scripts.sync-from-iphone"
    ];

    devPkgs = declPackageSet [
      "cargo"
      "clang"
      "lua"
      "nodejs"
      "patchelf"
      "rustc"
      "tree-sitter"
    ];


    # INDIVIDUAL PACKAGE DEFINITIONS

    cargo.persist.byStore.plaintext = [ ".cargo" ];

    # auth token, preferences
    delfin.persist.byStore.private = [ ".config/delfin" ];

    # creds, but also 200 MB of node modules, etc
    discord.persist.byStore.private = [ ".config/discord" ];

    endless-sky.persist.byStore.plaintext = [ ".local/share/endless-sky" ];

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.byStore.plaintext = [ ".local/share/Emote" ];

    fluffychat-moby.persist.byStore.plaintext = [ ".local/share/chat.fluffy.fluffychat" ];

    font-manager.package = pkgs.font-manager.override {
      # build without the "Google Fonts" integration feature, to save closure / avoid webkitgtk_4_0
      withWebkit = false;
    };

    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    gh.persist.byStore.private = [ ".config/gh" ];

    gnome-2048.persist.byStore.plaintext = [ ".local/share/gnome-2048/scores" ];

    "gnome.gnome-maps".persist.byStore.plaintext = [ ".cache/shumate" ];
    "gnome.gnome-maps".persist.byStore.private = [ ".local/share/maps-places.json" ];

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];

    mumble.persist.byStore.private = [ ".local/share/Mumble" ];

    # settings (electron app)
    obsidian.persist.byStore.plaintext = [ ".config/obsidian" ];

    python3-repl.package = pkgs.python3.withPackages (ps: with ps; [
      requests
    ]);

    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];

    # printer/filament settings
    slic3r.persist.byStore.plaintext = [ ".Slic3r" ];

    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];

    superTux.persist.byStore.plaintext = [ ".local/share/supertux2" ];

    tdesktop.persist.byStore.private = [ ".local/share/TelegramDesktop" ];

    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    vvvvvv.persist.byStore.plaintext = [ ".local/share/VVVVVV" ];

    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    yarn.persist.byStore.plaintext = [ ".cache/yarn" ];
  };

  programs.feedbackd = lib.mkIf config.sane.programs.feedbackd.enabled {
    enable = true;
  };
}
