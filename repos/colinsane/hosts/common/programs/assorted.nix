{ config, lib, pkgs, ... }:

let
  declPackageSet = pkgs: {
    packageUnwrapped = null;
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
      "bridge-utils"  # for brctl; debug linux "bridge" inet devices
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
      # "iw"
      "jq"
      "killall"
      "libcap_ng"  # for `netcap`
      "lsof"
      # "miniupnpc"
      "nano"
      #  "ncdu"  # ncurses disk usage. doesn't cross compile (zig)
      "neovim"
      "netcat"
      "nethogs"
      "nmap"
      "nvme-cli"  # nvme
      # "openssl"
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
      "usbutils"  # lsusb
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
      # "clinfo"
      # "dmidecode"
      "dtrx"  # `unar` alternative, "Do The Right eXtraction"
      # "efivar"
      "eza"  # a better 'ls'
      # "flashrom"
      "git"  # needed as a user package, for config.
      # "gnupg"
      # "gocryptfs"
      # "gopass"
      # "gopass-jsonapi"
      # "helix"  # text editor
      # "libsecret"  # for managing user keyrings (secret-tool)
      # "lm_sensors"  # for sensors-detect
      # "lshw"
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
      # "snapper"
      "sops"  # for manually viewing secrets; outside `sane-secrets` (TODO: improve sane-secrets!)
      "speedtest-cli"
      # "ssh-to-age"
      "sudo"
      # "tageditor"  # music tagging
      # "unar"
      "unzip"
      "wireguard-tools"  # for `wg`
      "xdg-utils"  # for xdg-open
      # "yarn"
      "zsh"
    ];

    pcConsoleUtils = declPackageSet [
      # "gh"  # MS GitHub cli
      "nix-index"
      "nixpkgs-review"
      "sane-scripts.dev"
      "sequoia"
    ];

    consoleMediaUtils = declPackageSet [
      # "catt"  # cast videos to chromecast
      "ffmpeg"
      "go2tv"  # cast videos to UPNP/DLNA device (i.e. tv).
      "imagemagick"
      "sox"
      "yt-dlp"
    ];

    pcTuiApps = declPackageSet [
      "aerc"  # email client
      # "msmtp"  # sendmail
      # "offlineimap"  # email mailbox sync
      # "sfeed"  # RSS fetcher
      "visidata"  # TUI spreadsheet viewer/editor
      "w3m"  # web browser
    ];

    iphoneUtils = declPackageSet [
      # "ifuse"
      # "ipfs"
      # "libimobiledevice"
      "sane-scripts.sync-from-iphone"
    ];

    devPkgs = declPackageSet [
      "cargo"
      "clang"
      "lua"
      "nodejs"
      "patchelf"
      "rustc"
      # "tree-sitter"
    ];


    # INDIVIDUAL PACKAGE DEFINITIONS
    blanket.sandbox.method = "bwrap";
    blanket.sandbox.wrapperType = "wrappedDerivation";

    "cacert.unbundled".sandbox.enable = false;

    cargo.persist.byStore.plaintext = [ ".cargo" ];

    # auth token, preferences
    delfin.sandbox.method = "bwrap";
    delfin.sandbox.wrapperType = "wrappedDerivation";
    delfin.sandbox.whitelistDri = true;
    delfin.persist.byStore.private = [ ".config/delfin" ];

    # creds, but also 200 MB of node modules, etc
    discord.sandbox.method = "bwrap";
    discord.sandbox.wrapperType = "wrappedDerivation";
    discord.persist.byStore.private = [ ".config/discord" ];

    dtc.sandbox.method = "bwrap";
    dtc.sandbox.autodetectCliPaths = true;  # TODO:sandbox: untested

    endless-sky.persist.byStore.plaintext = [ ".local/share/endless-sky" ];

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.byStore.plaintext = [ ".local/share/Emote" ];

    eza.sandbox.method = "landlock";  # ls replacement
    eza.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    eza.sandbox.autodetectCliPaths = true;
    eza.sandbox.whitelistPwd = true;

    fd.sandbox.method = "landlock";
    fd.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    fd.sandbox.autodetectCliPaths = true;
    fd.sandbox.whitelistPwd = true;

    ffmpeg.sandbox.method = "bwrap";
    ffmpeg.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    ffmpeg.sandbox.autodetectCliPaths = "existingFileOrParent";  # it outputs uncreated files -> parent dir needs mounting

    file.sandbox.method = "bwrap";
    file.sandbox.wrapperType = "wrappedDerivation";
    file.sandbox.autodetectCliPaths = true;

    fluffychat-moby.persist.byStore.plaintext = [ ".local/share/chat.fluffy.fluffychat" ];

    font-manager.sandbox.method = "bwrap";
    font-manager.sandbox.wrapperType = "inplace";  # .desktop and dbus .service file refer to /libexec
    font-manager.packageUnwrapped = pkgs.font-manager.override {
      # build without the "Google Fonts" integration feature, to save closure / avoid webkitgtk_4_0
      withWebkit = false;
    };

    gawk.sandbox.method = "bwrap";  # TODO:sandbox: untested
    gawk.sandbox.wrapperType = "inplace";  # share/gawk libraries refer to /libexec
    gawk.sandbox.autodetectCliPaths = true;

    gdb.sandbox.enable = false;  # gdb doesn't sandbox well. i don't know how you could.
    # gdb.sandbox.method = "landlock";  # permission denied when trying to attach, even as root
    gdb.sandbox.wrapperType = "wrappedDerivation";
    gdb.sandbox.autodetectCliPaths = true;

    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    gh.persist.byStore.private = [ ".config/gh" ];

    gimp.sandbox.method = "bwrap";
    gimp.sandbox.wrapperType = "wrappedDerivation";
    gimp.sandbox.extraHomePaths = [
      "Pictures"
      "dev"
      "ref"
      "tmp"
    ];
    gimp.sandbox.extraPaths = [
      "/mnt/servo-media/Pictures"
    ];
    gimp.sandbox.autodetectCliPaths = true;

    "gnome.gnome-calculator".sandbox.method = "bwrap";
    "gnome.gnome-calculator".sandbox.wrapperType = "inplace";  # /libexec/gnome-calculator-search-provider

    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    "gnome.gnome-calendar".sandbox.method = "bwrap";
    "gnome.gnome-calendar".sandbox.wrapperType = "wrappedDerivation";

    "gnome.gnome-clocks".sandbox.method = "bwrap";
    "gnome.gnome-clocks".sandbox.wrapperType = "wrappedDerivation";
    "gnome.gnome-clocks".persist.byStore.private = [
      ".config/dconf"
    ];

    gnome-2048.sandbox.method = "bwrap";
    gnome-2048.sandbox.wrapperType = "wrappedDerivation";
    gnome-2048.persist.byStore.plaintext = [ ".local/share/gnome-2048/scores" ];

    # TODO: gnome-maps: move to own file
    "gnome.gnome-maps".persist.byStore.plaintext = [ ".cache/shumate" ];
    "gnome.gnome-maps".persist.byStore.private = [ ".local/share/maps-places.json" ];

    # hitori rules:
    # - click to shade a tile
    # 1. no number may appear unshaded more than once in the same row/column
    # 2. no two shaded tiles can be direct N/S/E/W neighbors
    # - win once (1) and (2) are satisfied
    "gnome.hitori".sandbox.method = "bwrap";
    "gnome.hitori".sandbox.wrapperType = "wrappedDerivation";

    # jq.sandbox.autodetectCliPaths = true;  # liable to over-detect

    mercurial.sandbox.method = "bwrap";  # TODO:sandbox: untested
    mercurial.sandbox.wrapperType = "wrappedDerivation";
    mercurial.sandbox.whitelistPwd = true;
    mimeo.sandbox.method = "capshonly";  # xdg-open replacement

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];

    mumble.persist.byStore.private = [ ".local/share/Mumble" ];

    nano.sandbox.method = "bwrap";
    nano.sandbox.wrapperType = "wrappedDerivation";
    nano.sandbox.autodetectCliPaths = "existingFileOrParent";

    # settings (electron app)
    obsidian.persist.byStore.plaintext = [ ".config/obsidian" ];

    pavucontrol.sandbox.method = "bwrap";
    pavucontrol.sandbox.wrapperType = "wrappedDerivation";

    pwvucontrol.sandbox.method = "bwrap";
    pwvucontrol.sandbox.wrapperType = "wrappedDerivation";

    python3-repl.packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      requests
    ]);

    rsync.sandbox.method = "bwrap";  # TODO:sandbox: untested
    rsync.sandbox.wrapperType = "wrappedDerivation";
    rsync.sandbox.autodetectCliPaths = "existingFileOrParent";

    sequoia.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sequoia.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    sequoia.sandbox.whitelistPwd = true;
    sequoia.sandbox.autodetectCliPaths = true;

    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];

    # printer/filament settings
    slic3r.persist.byStore.plaintext = [ ".Slic3r" ];

    sops.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sops.sandbox.wrapperType = "wrappedDerivation";
    sops.sandbox.extraHomePaths = [
      ".config/sops"
      "dev/nixos"
      # TODO: sops should only need access to knowledge/secrets,
      # except that i currently put its .sops.yaml config in the root of ~/knowledge
      "knowledge"
    ];

    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];

    subversion.sandbox.method = "bwrap";
    subversion.sandbox.wrapperType = "wrappedDerivation";
    subversion.sandbox.whitelistPwd = true;
    sudo.sandbox.enable = false;

    superTux.persist.byStore.plaintext = [ ".local/share/supertux2" ];

    swaylock.sandbox.enable = false;  #< neither landlock nor bwrap works. pam_authenticate failed: invalid credentials. does it rely on SUID?

    tdesktop.persist.byStore.private = [ ".local/share/TelegramDesktop" ];

    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    tcpdump.sandbox.method = "landlock";
    tcpdump.sandbox.wrapperType = "wrappedDerivation";
    tcpdump.sandbox.autodetectCliPaths = "existingFileOrParent";
    tcpdump.sandbox.capabilities = [ "net_admin" "net_raw" ];
    tree.sandbox.method = "landlock";
    tree.sandbox.wrapperType = "wrappedDerivation";
    tree.sandbox.autodetectCliPaths = true;
    tree.sandbox.whitelistPwd = true;

    unzip.sandbox.method = "bwrap";
    unzip.sandbox.wrapperType = "wrappedDerivation";
    unzip.sandbox.autodetectCliPaths = "existingFileOrParent";
    unzip.sandbox.whitelistPwd = true;

    visidata.sandbox.method = "bwrap";  # TODO:sandbox: untested
    visidata.sandbox.wrapperType = "wrappedDerivation";
    visidata.sandbox.autodetectCliPaths = true;

    vvvvvv.persist.byStore.plaintext = [ ".local/share/VVVVVV" ];

    wget.sandbox.method = "bwrap";  # TODO:sandbox: untested
    wget.sandbox.wrapperType = "wrappedDerivation";
    wget.sandbox.whitelistPwd = true;  # saves to pwd by default

    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    xdg-utils.sandbox.method = "capshonly";
    xdg-utils.sandbox.wrapperType = "wrappedDerivation";

    yarn.persist.byStore.plaintext = [ ".cache/yarn" ];

    yt-dlp.sandbox.method = "bwrap";  # TODO:sandbox: untested
    yt-dlp.sandbox.wrapperType = "wrappedDerivation";
    yt-dlp.sandbox.whitelistPwd = true;  # saves to pwd by default
  };

  programs.feedbackd = lib.mkIf config.sane.programs.feedbackd.enabled {
    enable = true;
  };

  programs.firejail = lib.mkIf config.sane.programs.firejail.enabled {
    enable = true;  #< install the suid binary
  };
}
