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

    # packages which are unavoidably enabled system-wide by default nixos deployment
    # the only real reason to make a proper package set out of these is for documentation
    # and to allow them to be easily replaced by sandboxed versions.
    nixosBuiltins = {
      enableFor.system = lib.mkDefault true;
      packageUnwrapped = null;
      suggestedPrograms = [ "nixosBuiltinsNet" ]
        ++ lib.optionals config.networking.wireless.enable [ "nixosBuiltinsWireless" ];
    };
    nixosBuiltinsNet = declPackageSet [
      # from nixos/modules/tasks/network-interfaces.nix
      "host"
      "iproute2"
      "iputils"
      "nettools"
    ];
    nixosBuiltinsWireless = declPackageSet [
      # from nixos/modules/tasks/network-interfaces.nix
      # if config.networking.wireless.enable
      "wirelesstools"
      "iw"
    ];

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
      # "libcap_ng"  # for `netcap`
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
      "strings"
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

    alsaUtils.sandbox.method = "landlock";
    alsaUtils.sandbox.wrapperType = "wrappedDerivation";
    alsaUtils.sandbox.whitelistAudio = true;  #< not strictly necessary?

    blanket.sandbox.method = "bwrap";
    blanket.sandbox.wrapperType = "wrappedDerivation";
    blanket.sandbox.whitelistAudio = true;
    # blanket.sandbox.whitelistDbus = [ "user" ];  # TODO: untested
    blanket.sandbox.whitelistWayland = true;

    blueberry.sandbox.method = "bwrap";
    blueberry.sandbox.wrapperType = "wrappedDerivation";
    blueberry.sandbox.whitelistWayland = true;
    blueberry.sandbox.extraPaths = [
      "/dev/rfkill"
      "/run/dbus"
      "/sys/class/rfkill"
      "/sys/devices"
    ];

    bridge-utils.sandbox.method = "bwrap";  #< bwrap, landlock: both work
    bridge-utils.sandbox.wrapperType = "wrappedDerivation";
    bridge-utils.sandbox.net = "all";

    brightnessctl.sandbox.method = "landlock";  # also bwrap, but landlock is more responsive
    brightnessctl.sandbox.wrapperType = "wrappedDerivation";
    brightnessctl.sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/class/leds"
      "/sys/devices"
    ];
    brightnessctl.sandbox.whitelistDbus = [ "system" ];

    btrfs-progs.sandbox.method = "bwrap";  #< bwrap, landlock: both work
    btrfs-progs.sandbox.wrapperType = "wrappedDerivation";
    btrfs-progs.sandbox.autodetectCliPaths = "existing";  # e.g. `btrfs filesystem df /my/fs`

    "cacert.unbundled".sandbox.enable = false;

    cargo.persist.byStore.plaintext = [ ".cargo" ];

    # cryptsetup: typical use is `cryptsetup open /dev/loopxyz mappedName`, and creates `/dev/mapper/mappedName`
    cryptsetup.sandbox.method = "landlock";
    cryptsetup.sandbox.wrapperType = "wrappedDerivation";
    cryptsetup.sandbox.extraPaths = [
      "/dev/mapper"
      "/dev/random"
      "/dev/urandom"
      "/run"  #< it needs the whole directory, at least if using landlock
      "/proc"
      "/sys/dev/block"
      "/sys/devices"
    ];
    cryptsetup.sandbox.capabilities = [ "sys_admin" ];
    cryptsetup.sandbox.autodetectCliPaths = "existing";

    ddrescue.sandbox.method = "landlock";  # TODO:sandbox: untested
    ddrescue.sandbox.wrapperType = "wrappedDerivation";
    ddrescue.sandbox.autodetectCliPaths = "existingFileOrParent";

    # auth token, preferences
    delfin.sandbox.method = "bwrap";
    delfin.sandbox.wrapperType = "wrappedDerivation";
    delfin.sandbox.whitelistAudio = true;
    # delfin.sandbox.whitelistDbus = [ "user" ];  # TODO: untested
    delfin.sandbox.whitelistDri = true;
    delfin.sandbox.whitelistWayland = true;
    delfin.sandbox.net = "clearnet";
    delfin.persist.byStore.private = [ ".config/delfin" ];

    dig.sandbox.method = "bwrap";
    dig.sandbox.wrapperType = "wrappedDerivation";
    dig.sandbox.net = "all";

    # creds, but also 200 MB of node modules, etc
    discord.sandbox.method = "bwrap";
    discord.sandbox.wrapperType = "inplace";  #< /opt-style packaging
    discord.sandbox.whitelistAudio = true;
    discord.sandbox.whitelistDbus = [ "user" ];  # needed for xdg-open
    discord.sandbox.whitelistWayland = true;
    discord.sandbox.net = "clearnet";
    discord.persist.byStore.private = [ ".config/discord" ];

    dtc.sandbox.method = "bwrap";
    dtc.sandbox.autodetectCliPaths = true;  # TODO:sandbox: untested

    dtrx.sandbox.method = "bwrap";
    dtrx.sandbox.wrapperType = "wrappedDerivation";
    dtrx.sandbox.whitelistPwd = true;
    dtrx.sandbox.autodetectCliPaths = "existing";  #< for the archive

    e2fsprogs.sandbox.method = "landlock";
    e2fsprogs.sandbox.wrapperType = "wrappedDerivation";
    e2fsprogs.sandbox.autodetectCliPaths = "existing";

    efibootmgr.sandbox.method = "landlock";
    efibootmgr.sandbox.wrapperType = "wrappedDerivation";
    efibootmgr.sandbox.extraPaths = [
      "/sys/firmware/efi"
    ];

    electrum.sandbox.method = "bwrap";  # TODO:sandbox: untested
    electrum.sandbox.wrapperType = "wrappedDerivation";
    electrum.sandbox.net = "all";  # TODO: probably want to make this run behind a VPN, always
    electrum.sandbox.whitelistWayland = true;
    electrum.persist.byStore.cryptClearOnBoot = [ ".electrum" ];  #< TODO: use XDG dirs!

    endless-sky.persist.byStore.plaintext = [ ".local/share/endless-sky" ];
    endless-sky.sandbox.method = "bwrap";
    endless-sky.sandbox.wrapperType = "wrappedDerivation";
    endless-sky.sandbox.whitelistAudio = true;
    endless-sky.sandbox.whitelistDri = true;
    endless-sky.sandbox.whitelistWayland = true;

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.byStore.plaintext = [ ".local/share/Emote" ];

    ethtool.sandbox.method = "landlock";
    ethtool.sandbox.wrapperType = "wrappedDerivation";
    ethtool.sandbox.capabilities = [ "net_admin" ];

    eza.sandbox.method = "landlock";  # ls replacement
    eza.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    eza.sandbox.autodetectCliPaths = true;
    eza.sandbox.whitelistPwd = true;

    fatresize.sandbox.method = "landlock";
    fatresize.sandbox.wrapperType = "wrappedDerivation";
    fatresize.sandbox.autodetectCliPaths = "parent";  # /dev/sda1 -> needs /dev/sda

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

    # fuzzel: TODO: re-enable sandbox. i use fuzzel both as an entry system (snippets) AND an app-launcher.
    #   as an app-launcher, it cannot be sandboxed without over-restricting the app it launches.
    #   should probably make it not be an app-launcher
    fuzzel.sandbox.enable = false;
    fuzzel.sandbox.method = "bwrap";  #< landlock nearly works, but unable to open ~/.cache
    fuzzel.sandbox.wrapperType = "wrappedDerivation";
    fuzzel.sandbox.whitelistWayland = true;
    fuzzel.persist.byStore.private = [ ".cache/fuzzel" ];  #< this is a file of recent selections

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
    gimp.sandbox.whitelistWayland = true;
    gimp.sandbox.extraHomePaths = [
      "Pictures"
      "Pictures/servo-macros"
      "dev"
      "ref"
      "tmp"
    ];
    gimp.sandbox.autodetectCliPaths = true;

    "gnome.gnome-calculator".sandbox.method = "bwrap";
    "gnome.gnome-calculator".sandbox.wrapperType = "inplace";  # /libexec/gnome-calculator-search-provider
    "gnome.gnome-calculator".sandbox.whitelistWayland = true;

    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    "gnome.gnome-calendar".sandbox.method = "bwrap";
    "gnome.gnome-calendar".sandbox.wrapperType = "wrappedDerivation";
    "gnome.gnome-calendar".sandbox.whitelistWayland = true;

    "gnome.gnome-clocks".sandbox.method = "bwrap";
    "gnome.gnome-clocks".sandbox.wrapperType = "wrappedDerivation";
    "gnome.gnome-clocks".sandbox.whitelistWayland = true;
    "gnome.gnome-clocks".persist.byStore.private = [
      ".config/dconf"
    ];

    gnome-2048.sandbox.method = "bwrap";
    gnome-2048.sandbox.wrapperType = "wrappedDerivation";
    gnome-2048.sandbox.whitelistWayland = true;
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
    "gnome.hitori".sandbox.whitelistWayland = true;

    hase.sandbox.method = "bwrap";
    hase.sandbox.wrapperType = "wrappedDerivation";
    hase.sandbox.net = "clearnet";
    hase.sandbox.whitelistAudio = true;
    hase.sandbox.whitelistDri = true;
    hase.sandbox.whitelistWayland = true;

    # hdparm: has to be run as sudo. e.g. `sudo hdparm -i /dev/sda`
    hdparm.sandbox.method = "bwrap";
    hdparm.sandbox.wrapperType = "wrappedDerivation";
    hdparm.sandbox.autodetectCliPaths = true;

    host.sandbox.method = "landlock";
    host.sandbox.wrapperType = "wrappedDerivation";
    host.sandbox.net = "all";  #< technically, only needs to contact localhost's DNS server

    htop.sandbox.method = "landlock";
    htop.sandbox.wrapperType = "wrappedDerivation";
    htop.sandbox.extraPaths = [
      "/proc"
      "/sys/devices"
    ];

    iftop.sandbox.method = "landlock";
    iftop.sandbox.wrapperType = "wrappedDerivation";
    iftop.sandbox.capabilities = [ "net_raw" ];

    # inetutils: ping, ifconfig, hostname, traceroute, whois, ....
    # N.B.: inetutils' `ping` is shadowed by iputils' ping (by nixos, intentionally).
    inetutils.sandbox.method = "landlock";  # want to keep the same netns, at least.
    inetutils.sandbox.wrapperType = "wrappedDerivation";

    inkscape.sandbox.method = "bwrap";
    inkscape.sandbox.wrapperType = "wrappedDerivation";
    inkscape.sandbox.whitelistWayland = true;
    inkscape.sandbox.extraHomePaths = [
      "Pictures"
      "Pictures/servo-macros"
      "dev"
      "ref"
      "tmp"
    ];
    inkscape.sandbox.autodetectCliPaths = true;

    iotop.sandbox.method = "landlock";
    iotop.sandbox.wrapperType = "wrappedDerivation";
    iotop.sandbox.extraPaths = [
      "/proc"
    ];
    iotop.sandbox.capabilities = [ "net_admin" ];

    # provides `ip`, `routel`, others
    iproute2.sandbox.method = "landlock";
    iproute2.sandbox.wrapperType = "wrappedDerivation";
    iproute2.sandbox.net = "all";
    iproute2.sandbox.capabilities = [ "net_admin" ];

    iptables.sandbox.method = "landlock";
    iptables.sandbox.wrapperType = "wrappedDerivation";
    iptables.sandbox.net = "all";
    iptables.sandbox.capabilities = [ "net_admin" ];

    # iputils provides `ping` (and arping, clockdiff, tracepath)
    iputils.sandbox.method = "landlock";
    iputils.sandbox.wrapperType = "wrappedDerivation";
    iputils.sandbox.net = "all";
    iputils.sandbox.capabilities = [ "net_raw" ];

    iw.sandbox.method = "landlock";
    iw.sandbox.wrapperType = "wrappedDerivation";
    iw.sandbox.net = "all";
    iw.sandbox.capabilities = [ "net_admin" ];

    # jq.sandbox.autodetectCliPaths = true;  # liable to over-detect

    killall.sandbox.method = "landlock";
    killall.sandbox.wrapperType = "wrappedDerivation";
    killall.sandbox.extraPaths = [
      "/proc"
    ];

    krita.sandbox.method = "bwrap";
    krita.sandbox.wrapperType = "wrappedDerivation";
    krita.sandbox.whitelistWayland = true;
    krita.sandbox.autodetectCliPaths = "existing";
    krita.sandbox.extraHomePaths = [
      "dev"
      "Pictures"
      "Pictures/servo-macros"
      "ref"
      "tmp"
    ];

    libcap_ng.sandbox.enable = false;  # there's something about /proc/$pid/fd which breaks `readlink`/stat with every sandbox technique (except capsh-only)

    libnotify.sandbox.method = "bwrap";
    libnotify.sandbox.wrapperType = "wrappedDerivation";
    libnotify.sandbox.whitelistDbus = [ "user" ];  # notify-send

    losslesscut-bin.sandbox.method = "bwrap";
    losslesscut-bin.sandbox.wrapperType = "wrappedDerivation";
    losslesscut-bin.sandbox.extraHomePaths = [
      "Music"
      "Pictures"  # i have some videos in there too.
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "tmp"
    ];
    losslesscut-bin.sandbox.whitelistAudio = true;
    losslesscut-bin.sandbox.whitelistDri = true;
    losslesscut-bin.sandbox.whitelistWayland = true;
    losslesscut-bin.sandbox.whitelistX = true;

    lsof.sandbox.method = "capshonly";  # lsof doesn't sandbox under bwrap or even landlock w/ full access to /
    lsof.sandbox.wrapperType = "wrappedDerivation";

    "mate.engrampa".sandbox.method = "bwrap";  # TODO:sandbox: untested
    "mate.engrampa".sandbox.wrapperType = "inplace";
    "mate.engrampa".sandbox.whitelistWayland = true;
    "mate.engrampa".sandbox.autodetectCliPaths = "existingFileOrParent";
    "mate.engrampa".sandbox.extraHomePaths = [
      "archive"
      "Books"
      "records"
      "ref"
      "tmp"
    ];

    mercurial.sandbox.method = "bwrap";  # TODO:sandbox: untested
    mercurial.sandbox.wrapperType = "wrappedDerivation";
    mercurial.sandbox.net = "clearnet";
    mercurial.sandbox.whitelistPwd = true;

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];

    mumble.persist.byStore.private = [ ".local/share/Mumble" ];

    nano.sandbox.method = "bwrap";
    nano.sandbox.wrapperType = "wrappedDerivation";
    nano.sandbox.autodetectCliPaths = "existingFileOrParent";

    netcat.sandbox.method = "landlock";
    netcat.sandbox.wrapperType = "wrappedDerivation";
    netcat.sandbox.net = "all";

    nethogs.sandbox.method = "capshonly";  # *partially* works under landlock w/ full access to /
    nethogs.sandbox.wrapperType = "wrappedDerivation";
    nethogs.sandbox.capabilities = [ "net_admin" "net_raw" ];

    # provides `arp`, `hostname`, `route`, `ifconfig`
    nettools.sandbox.method = "landlock";
    nettools.sandbox.wrapperType = "wrappedDerivation";
    nettools.sandbox.net = "all";
    nettools.sandbox.capabilities = [ "net_admin" "net_raw" ];
    nettools.sandbox.extraPaths = [
      "/proc"
    ];

    networkmanagerapplet.sandbox.method = "bwrap";
    networkmanagerapplet.sandbox.wrapperType = "wrappedDerivation";
    networkmanagerapplet.sandbox.whitelistWayland = true;
    networkmanagerapplet.sandbox.whitelistDbus = [ "system" ];

    nixpkgs-review.sandbox.method = "bwrap";
    nixpkgs-review.sandbox.wrapperType = "inplace";  #< shell completions use full paths
    nixpkgs-review.sandbox.net = "clearnet";
    nixpkgs-review.sandbox.whitelistPwd = true;
    nixpkgs-review.sandbox.extraPaths = [
      "/nix"
    ];

    nmon.sandbox.method = "landlock";
    nmon.sandbox.wrapperType = "wrappedDerivation";
    nmon.sandbox.extraPaths = [
      "/proc"
    ];

    # settings (electron app)
    obsidian.persist.byStore.plaintext = [ ".config/obsidian" ];

    parted.sandbox.method = "landlock";
    parted.sandbox.wrapperType = "wrappedDerivation";
    parted.sandbox.extraPaths = [
      "/dev"
    ];
    parted.sandbox.autodetectCliPaths = "existing";  #< sometimes you'll use parted on a device file.

    pavucontrol.sandbox.method = "bwrap";
    pavucontrol.sandbox.wrapperType = "wrappedDerivation";
    pavucontrol.sandbox.whitelistAudio = true;
    pavucontrol.sandbox.whitelistWayland = true;

    pciutils.sandbox.method = "landlock";
    pciutils.sandbox.wrapperType = "wrappedDerivation";
    pciutils.sandbox.extraPaths = [
      "/sys/bus/pci"
      "/sys/devices"
    ];

    "perlPackages.FileMimeInfo".sandbox.enable = false;  #< TODO: sandbox `mimetype` but not `mimeopen`.

    powertop.sandbox.method = "landlock";
    powertop.sandbox.wrapperType = "wrappedDerivation";
    powertop.sandbox.capabilities = [ "ipc_lock" "sys_admin" ];
    powertop.sandbox.extraPaths = [
      "/proc"
      "/sys/class"
      "/sys/devices"
      "/sys/kernel"
    ];

    pstree.sandbox.method = "landlock";
    pstree.sandbox.wrapperType = "wrappedDerivation";
    pstree.sandbox.extraPaths = [
      "/proc"
    ];

    pulsemixer.sandbox.method = "landlock";
    pulsemixer.sandbox.wrapperType = "wrappedDerivation";
    pulsemixer.sandbox.whitelistAudio = true;

    pwvucontrol.sandbox.method = "bwrap";
    pwvucontrol.sandbox.wrapperType = "wrappedDerivation";
    pwvucontrol.sandbox.whitelistAudio = true;
    pwvucontrol.sandbox.whitelistWayland = true;

    python3-repl.packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      requests
    ]);

    qemu.sandbox.enable = false;  #< it's a launcher

    rsync.sandbox.method = "bwrap";  # TODO:sandbox: untested
    rsync.sandbox.wrapperType = "wrappedDerivation";
    rsync.sandbox.net = "clearnet";
    rsync.sandbox.autodetectCliPaths = "existingFileOrParent";

    screen.sandbox.enable = false;  #< tty; needs to run anything

    sequoia.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sequoia.sandbox.wrapperType = "wrappedDerivation";  # slow to build
    sequoia.sandbox.whitelistPwd = true;
    sequoia.sandbox.autodetectCliPaths = true;

    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];
    shattered-pixel-dungeon.sandbox.method = "bwrap";
    shattered-pixel-dungeon.sandbox.wrapperType = "wrappedDerivation";
    shattered-pixel-dungeon.sandbox.whitelistAudio = true;
    shattered-pixel-dungeon.sandbox.whitelistDri = true;
    shattered-pixel-dungeon.sandbox.whitelistWayland = true;

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

    soundconverter.sandbox.method = "bwrap";
    soundconverter.sandbox.wrapperType = "wrappedDerivation";
    soundconverter.sandbox.whitelistWayland = true;
    soundconverter.sandbox.extraHomePaths = [
      "Music"
      "tmp"
      "use"
    ];
    soundconverter.sandbox.extraPaths = [
      "/mnt/servo/media/Music"
      "/mnt/servo/media/games"
    ];
    soundconverter.sandbox.autodetectCliPaths = "existingFileOrParent";

    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];
    space-cadet-pinball.sandbox.method = "bwrap";
    space-cadet-pinball.sandbox.wrapperType = "wrappedDerivation";
    space-cadet-pinball.sandbox.whitelistAudio = true;
    space-cadet-pinball.sandbox.whitelistDri = true;
    space-cadet-pinball.sandbox.whitelistWayland = true;

    speedtest-cli.sandbox.method = "bwrap";
    speedtest-cli.sandbox.wrapperType = "wrappedDerivation";
    speedtest-cli.sandbox.net = "all";

    strace.sandbox.enable = false;  #< needs to `exec` its args, and therefore support *anything*

    subversion.sandbox.method = "bwrap";
    subversion.sandbox.wrapperType = "wrappedDerivation";
    subversion.sandbox.net = "clearnet";
    subversion.sandbox.whitelistPwd = true;
    sudo.sandbox.enable = false;

    superTux.sandbox.method = "bwrap";
    superTux.sandbox.wrapperType = "inplace";  # package Makefile incorrectly installs to $out/games/superTux instead of $out/share/games
    superTux.sandbox.whitelistAudio = true;
    superTux.sandbox.whitelistDri = true;
    superTux.sandbox.whitelistWayland = true;
    superTux.persist.byStore.plaintext = [ ".local/share/supertux2" ];

    "sway-contrib.grimshot".sandbox.method = "bwrap";
    "sway-contrib.grimshot".sandbox.wrapperType = "wrappedDerivation";
    "sway-contrib.grimshot".sandbox.whitelistWayland = true;
    "sway-contrib.grimshot".sandbox.whitelistDbus = [ "user" ];
    "sway-contrib.grimshot".sandbox.autodetectCliPaths = "existingFileOrParent";

    tcpdump.sandbox.method = "landlock";
    tcpdump.sandbox.wrapperType = "wrappedDerivation";
    tcpdump.sandbox.net = "all";
    tcpdump.sandbox.autodetectCliPaths = "existingFileOrParent";
    tcpdump.sandbox.capabilities = [ "net_admin" "net_raw" ];

    tdesktop.persist.byStore.private = [ ".local/share/TelegramDesktop" ];

    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    tree.sandbox.method = "landlock";
    tree.sandbox.wrapperType = "wrappedDerivation";
    tree.sandbox.autodetectCliPaths = true;
    tree.sandbox.whitelistPwd = true;

    tumiki-fighters.sandbox.method = "bwrap";
    tumiki-fighters.sandbox.wrapperType = "wrappedDerivation";
    tumiki-fighters.sandbox.whitelistAudio = true;
    tumiki-fighters.sandbox.whitelistDri = true;  #< not strictly necessary, but triples CPU perf
    tumiki-fighters.sandbox.whitelistWayland = true;
    tumiki-fighters.sandbox.whitelistX = true;

    util-linux.sandbox.enable = false;  #< TODO: possible to sandbox if i specific a different profile for each of its ~50 binaries

    unzip.sandbox.method = "bwrap";
    unzip.sandbox.wrapperType = "wrappedDerivation";
    unzip.sandbox.autodetectCliPaths = "existingFileOrParent";
    unzip.sandbox.whitelistPwd = true;

    usbutils.sandbox.method = "bwrap";  # breaks `usbhid-dump`, but `lsusb`, `usb-devices` work
    usbutils.sandbox.wrapperType = "wrappedDerivation";
    usbutils.sandbox.extraPaths = [
      "/sys/devices"
      "/sys/bus/usb"
    ];

    visidata.sandbox.method = "bwrap";  # TODO:sandbox: untested
    visidata.sandbox.wrapperType = "wrappedDerivation";
    visidata.sandbox.autodetectCliPaths = true;

    vvvvvv.sandbox.method = "bwrap";
    vvvvvv.sandbox.wrapperType = "wrappedDerivation";
    vvvvvv.sandbox.whitelistAudio = true;
    vvvvvv.sandbox.whitelistDri = true;  #< playable without, but burns noticably more CPU
    vvvvvv.sandbox.whitelistWayland = true;
    vvvvvv.persist.byStore.plaintext = [ ".local/share/VVVVVV" ];

    w3m.sandbox.method = "bwrap";
    w3m.sandbox.wrapperType = "wrappedDerivation";
    w3m.sandbox.net = "all";
    w3m.sandbox.extraHomePaths = [
      # little-used feature, but you can save web pages :)
      "tmp"
    ];

    wdisplays.sandbox.method = "bwrap";
    wdisplays.sandbox.wrapperType = "wrappedDerivation";
    wdisplays.sandbox.whitelistWayland = true;

    wget.sandbox.method = "bwrap";
    wget.sandbox.wrapperType = "wrappedDerivation";
    wget.sandbox.net = "all";
    wget.sandbox.whitelistPwd = true;  # saves to pwd by default

    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    # provides `iwconfig`, `iwlist`, `iwpriv`, ...
    wirelesstools.sandbox.method = "landlock";
    wirelesstools.sandbox.wrapperType = "wrappedDerivation";
    wirelesstools.sandbox.capabilities = [ "net_admin" ];

    wl-clipboard.sandbox.method = "bwrap";
    wl-clipboard.sandbox.wrapperType = "wrappedDerivation";
    wl-clipboard.sandbox.whitelistWayland = true;

    xdg-desktop-portal-gtk.sandbox.method = "bwrap";
    xdg-desktop-portal-gtk.sandbox.wrapperType = "inplace";
    xdg-desktop-portal-gtk.sandbox.whitelistDbus = [ "user" ];  # speak to main xdg-desktop-portal
    xdg-desktop-portal-gtk.sandbox.whitelistWayland = true;
    xdg-desktop-portal-gtk.sandbox.extraHomePaths = [
      ".local/share/applications"  # file opener needs to find .desktop files, for their icon/name.
      # for file-chooser portal users (fractal, firefox, ...), need to provide anything they might want.
      # i think (?) portal users can only access the files here interactively, i.e. by me interacting with the portal's visual filechooser,
      # so shoving stuff here is trusting the portal but not granting any trust to the portal user.
      "Books"
      "Music"
      "Pictures"
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "archive"
      "dev"
      "ref"
      "tmp"
      "use"
    ];

    xdg-desktop-portal-wlr.sandbox.method = "bwrap";  # TODO:sandbox: untested
    xdg-desktop-portal-wlr.sandbox.wrapperType = "inplace";
    xdg-desktop-portal-wlr.sandbox.whitelistDbus = [ "user" ];  # speak to main xdg-desktop-portal
    xdg-desktop-portal-wlr.sandbox.whitelistWayland = true;

    xdg-terminal-exec.sandbox.enable = false;  # xdg-terminal-exec is a launcher for $TERM
    xterm.sandbox.enable = false;  # need to be able to do everything

    yarn.persist.byStore.plaintext = [ ".cache/yarn" ];

    yt-dlp.sandbox.method = "bwrap";  # TODO:sandbox: untested
    yt-dlp.sandbox.wrapperType = "wrappedDerivation";
    yt-dlp.sandbox.net = "all";
    yt-dlp.sandbox.whitelistPwd = true;  # saves to pwd by default
  };

  programs.feedbackd = lib.mkIf config.sane.programs.feedbackd.enabled {
    enable = true;
  };

  programs.firejail = lib.mkIf config.sane.programs.firejail.enabled {
    enable = true;  #< install the suid binary
  };
}
