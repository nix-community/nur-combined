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
      "forkstat"  # monitor every spawned/forked process
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
      "less"
      "lftp"
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
      "s6-rc"  # service manager
      "screen"
      "smartmontools"  # smartctl
      # "socat"
      "strace"
      "subversion"
      "tcpdump"
      "tree"
      "usbutils"  # lsusb
      "util-linux"  # lsblk, lscpu, etc
      "valgrind"
      "wget"
      "wirelesstools"  # iwlist
      # "xq"  # jq for XML
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
      # "cdrtools"
      # "clinfo"
      # "dmidecode"
      "dtrx"  # `unar` alternative, "Do The Right eXtraction"
      # "efivar"
      "eza"  # a better 'ls'
      # "flashrom"
      "git"  # needed as a user package, for config.
      # "glib"  # for `gsettings`
      # "gnupg"
      # "gocryptfs"
      # "gopass"
      # "gopass-jsonapi"
      # "helix"  # text editor
      "htop"  # needed as a user package, for ~/.config/htop
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
      "objdump"
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
      "strings"
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
      "blast-ugjka"  # cast audio to UPNP/DLNA devices (via pulseaudio sink)
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
    alsaUtils.sandbox.whitelistAudio = true;  #< not strictly necessary?

    backblaze-b2 = {};

    blanket.sandbox.method = "bwrap";
    blanket.sandbox.whitelistAudio = true;
    # blanket.sandbox.whitelistDbus = [ "user" ];  # TODO: untested
    blanket.sandbox.whitelistWayland = true;

    blueberry.sandbox.method = "bwrap";
    blueberry.sandbox.wrapperType = "inplace";  #< various /lib scripts refer to the bins by full path
    blueberry.sandbox.whitelistWayland = true;
    blueberry.sandbox.extraPaths = [
      "/dev/rfkill"
      "/run/dbus"
      "/sys/class/rfkill"
      "/sys/devices"
    ];

    bridge-utils.sandbox.method = "bwrap";  #< bwrap, landlock: both work
    bridge-utils.sandbox.net = "all";

    brightnessctl.sandbox.method = "landlock";  # also bwrap, but landlock is more responsive
    brightnessctl.sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/class/leds"
      "/sys/devices"
    ];
    brightnessctl.sandbox.whitelistDbus = [ "system" ];

    btrfs-progs.sandbox.method = "bwrap";  #< bwrap, landlock: both work
    btrfs-progs.sandbox.autodetectCliPaths = "existing";  # e.g. `btrfs filesystem df /my/fs`

    "cacert.unbundled".sandbox.enable = false;

    cargo.persist.byStore.plaintext = [ ".cargo" ];

    clang = {};

    # cryptsetup: typical use is `cryptsetup open /dev/loopxyz mappedName`, and creates `/dev/mapper/mappedName`
    cryptsetup.sandbox.method = "landlock";
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
    ddrescue.sandbox.autodetectCliPaths = "existingOrParent";

    # auth token, preferences
    delfin.sandbox.method = "bwrap";
    delfin.sandbox.whitelistAudio = true;
    delfin.sandbox.whitelistDbus = [ "user" ];  # else `mpris` plugin crashes the player
    delfin.sandbox.whitelistDri = true;
    delfin.sandbox.whitelistWayland = true;
    delfin.sandbox.net = "clearnet";
    delfin.persist.byStore.private = [ ".config/delfin" ];

    dig.sandbox.method = "bwrap";
    dig.sandbox.net = "all";

    # creds, but also 200 MB of node modules, etc
    discord.persist.byStore.private = [ ".config/discord" ];
    discord.suggestedPrograms = [ "xwayland" ];
    discord.sandbox.method = "bwrap";
    discord.sandbox.wrapperType = "inplace";  #< /opt-style packaging
    discord.sandbox.whitelistAudio = true;
    discord.sandbox.whitelistDbus = [ "user" ];  # needed for xdg-open
    discord.sandbox.whitelistWayland = true;
    discord.sandbox.whitelistX = true;
    discord.sandbox.net = "clearnet";
    discord.sandbox.extraHomePaths = [
      # still needs these paths despite it using the portal's file-chooser :?
      "Pictures/cat"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];

    dtc.sandbox.method = "bwrap";
    dtc.sandbox.autodetectCliPaths = true;  # TODO:sandbox: untested

    dtrx.sandbox.method = "bwrap";
    dtrx.sandbox.whitelistPwd = true;
    dtrx.sandbox.autodetectCliPaths = "existing";  #< for the archive

    duplicity = {};

    e2fsprogs.sandbox.method = "landlock";
    e2fsprogs.sandbox.autodetectCliPaths = "existing";

    efibootmgr.sandbox.method = "landlock";
    efibootmgr.sandbox.extraPaths = [
      "/sys/firmware/efi"
    ];

    eg25-control = {};

    electrum.sandbox.method = "bwrap";  # TODO:sandbox: untested
    electrum.sandbox.net = "all";  # TODO: probably want to make this run behind a VPN, always
    electrum.sandbox.whitelistWayland = true;
    electrum.persist.byStore.cryptClearOnBoot = [ ".electrum" ];  #< TODO: use XDG dirs!

    endless-sky.persist.byStore.plaintext = [ ".local/share/endless-sky" ];
    endless-sky.sandbox.method = "bwrap";
    endless-sky.sandbox.whitelistAudio = true;
    endless-sky.sandbox.whitelistDri = true;
    endless-sky.sandbox.whitelistWayland = true;

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.byStore.plaintext = [ ".local/share/Emote" ];

    ethtool.sandbox.method = "landlock";
    ethtool.sandbox.capabilities = [ "net_admin" ];

    # eza `ls` replacement
    # landlock is OK, only `whitelistPwd` doesn't make the intermediate symlinks traversable, so it breaks on e.g. ~/Videos/servo/Shows/foo
    # eza.sandbox.method = "landlock";
    eza.sandbox.method = "bwrap";
    eza.sandbox.autodetectCliPaths = true;
    eza.sandbox.whitelistPwd = true;
    eza.sandbox.extraHomePaths = [
      # so that e.g. `eza -l ~` can show which symlink exist
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    fatresize.sandbox.method = "landlock";
    fatresize.sandbox.autodetectCliPaths = "parent";  # /dev/sda1 -> needs /dev/sda

    fd.sandbox.method = "landlock";
    fd.sandbox.autodetectCliPaths = true;
    fd.sandbox.whitelistPwd = true;
    fd.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    ffmpeg.sandbox.method = "bwrap";
    ffmpeg.sandbox.autodetectCliPaths = "existingFileOrParent";  # it outputs uncreated files -> parent dir needs mounting

    file.sandbox.method = "bwrap";
    file.sandbox.autodetectCliPaths = true;

    findutils.sandbox.method = "bwrap";
    findutils.sandbox.autodetectCliPaths = true;
    findutils.sandbox.whitelistPwd = true;
    findutils.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    fluffychat-moby.persist.byStore.plaintext = [ ".local/share/chat.fluffy.fluffychat" ];

    font-manager.sandbox.method = "bwrap";
    font-manager.sandbox.whitelistWayland = true;
    font-manager.packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.font-manager.override {
      # build without the "Google Fonts" integration feature, to save closure / avoid webkitgtk_4_0
      withWebkit = false;
    });

    forkstat.sandbox.method = "landlock";  #< doesn't seem to support bwrap
    forkstat.sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"
    ];
    forkstat.sandbox.extraPaths = [
      "/proc"
    ];

    fuzzel.sandbox.method = "bwrap";  #< landlock nearly works, but unable to open ~/.cache
    fuzzel.sandbox.whitelistWayland = true;
    fuzzel.persist.byStore.private = [
      # this is a file of recent selections
      { path=".cache/fuzzel"; type="file"; }
    ];

    gawk.sandbox.method = "bwrap";  # TODO:sandbox: untested
    gawk.sandbox.wrapperType = "inplace";  # /share/gawk libraries refer to /libexec
    gawk.sandbox.autodetectCliPaths = true;

    gdb.sandbox.enable = false;  # gdb doesn't sandbox well. i don't know how you could.
    # gdb.sandbox.method = "landlock";  # permission denied when trying to attach, even as root
    gdb.sandbox.autodetectCliPaths = true;

    geoclue2-with-demo-agent = {};

    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    gh.persist.byStore.private = [ ".config/gh" ];

    gimp.sandbox.method = "bwrap";
    gimp.sandbox.whitelistX = true;
    gimp.sandbox.whitelistWayland = true;
    gimp.sandbox.extraHomePaths = [
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "dev"
      "ref"
      "tmp"
    ];
    gimp.sandbox.autodetectCliPaths = true;
    gimp.sandbox.extraPaths = [
      "/tmp"  # "Cannot open display:" if it can't mount /tmp 👀
    ];

    "gnome.gnome-calculator".sandbox.method = "bwrap";
    "gnome.gnome-calculator".sandbox.whitelistWayland = true;

    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    "gnome.gnome-calendar".sandbox.method = "bwrap";
    "gnome.gnome-calendar".sandbox.whitelistWayland = true;

    "gnome.gnome-clocks".sandbox.method = "bwrap";
    "gnome.gnome-clocks".sandbox.whitelistWayland = true;
    "gnome.gnome-clocks".suggestedPrograms = [ "dconf" ];

    # gnome-disks
    "gnome.gnome-disk-utility".sandbox.method = "bwrap";
    "gnome.gnome-disk-utility".sandbox.whitelistDbus = [ "system" ];
    "gnome.gnome-disk-utility".sandbox.whitelistWayland = true;

    # seahorse: dump gnome-keyring secrets.
    # N.B.: it can also manage ~/.ssh keys, but i explicitly don't add those to the sandbox for now.
    "gnome.seahorse".sandbox.method = "bwrap";
    "gnome.seahorse".sandbox.whitelistDbus = [ "user" ];
    "gnome.seahorse".sandbox.whitelistWayland = true;

    gnome-2048.sandbox.method = "bwrap";
    gnome-2048.sandbox.whitelistWayland = true;
    gnome-2048.persist.byStore.plaintext = [ ".local/share/gnome-2048/scores" ];

    gnome-frog.sandbox.method = "bwrap";
    gnome-frog.sandbox.whitelistWayland = true;
    gnome-frog.sandbox.whitelistDbus = [ "user" ];
    gnome-frog.sandbox.extraPaths = [
      # needed when processing screenshots
      "/tmp"
    ];
    gnome-frog.sandbox.extraHomePaths = [
      # for OCR'ing photos from disk
      "tmp"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
    ];
    gnome-frog.persist.byStore.cryptClearOnBoot = [
      ".local/share/tessdata"  # 15M; dunno what all it is.
    ];

    # hitori rules:
    # - click to shade a tile
    # 1. no number may appear unshaded more than once in the same row/column
    # 2. no two shaded tiles can be direct N/S/E/W neighbors
    # - win once (1) and (2) are satisfied
    "gnome.hitori".sandbox.method = "bwrap";
    "gnome.hitori".sandbox.whitelistWayland = true;

    gnugrep.sandbox.method = "bwrap";
    gnugrep.sandbox.autodetectCliPaths = true;
    gnugrep.sandbox.whitelistPwd = true;
    gnugrep.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    # sed: there is an edgecase of `--file=<foo>`, wherein `foo` won't be whitelisted.
    gnused.sandbox.method = "bwrap";
    gnused.sandbox.autodetectCliPaths = "existingFile";
    gnused.sandbox.whitelistPwd = true;  #< `-i` flag creates a temporary file in pwd (?) and then moves it.

    gpsd = {};

    gptfdisk.sandbox.method = "landlock";
    gptfdisk.sandbox.extraPaths = [
      "/dev"
    ];
    gptfdisk.sandbox.autodetectCliPaths = "existing";  #< sometimes you'll use gdisk on a device file.

    grim.sandbox.method = "bwrap";
    grim.sandbox.autodetectCliPaths = "existingOrParent";
    grim.sandbox.whitelistWayland = true;

    hase.sandbox.method = "bwrap";
    hase.sandbox.net = "clearnet";
    hase.sandbox.whitelistAudio = true;
    hase.sandbox.whitelistDri = true;
    hase.sandbox.whitelistWayland = true;

    # hdparm: has to be run as sudo. e.g. `sudo hdparm -i /dev/sda`
    hdparm.sandbox.method = "bwrap";
    hdparm.sandbox.autodetectCliPaths = true;

    host.sandbox.method = "landlock";
    host.sandbox.net = "all";  #< technically, only needs to contact localhost's DNS server

    iftop.sandbox.method = "landlock";
    iftop.sandbox.capabilities = [ "net_raw" ];

    # inetutils: ping, ifconfig, hostname, traceroute, whois, ....
    # N.B.: inetutils' `ping` is shadowed by iputils' ping (by nixos, intentionally).
    inetutils.sandbox.method = "landlock";  # want to keep the same netns, at least.

    inkscape.sandbox.method = "bwrap";
    inkscape.sandbox.whitelistWayland = true;
    inkscape.sandbox.extraHomePaths = [
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "dev"
      "ref"
      "tmp"
    ];
    inkscape.sandbox.autodetectCliPaths = true;

    iotop.sandbox.method = "landlock";
    iotop.sandbox.extraPaths = [
      "/proc"
    ];
    iotop.sandbox.capabilities = [ "net_admin" ];

    # provides `ip`, `routel`, others
    iproute2.sandbox.method = "landlock";
    iproute2.sandbox.net = "all";
    iproute2.sandbox.capabilities = [ "net_admin" ];
    iproute2.sandbox.extraPaths = [
      "/run/netns"  # for `ip netns ...` to work
      "/var/run/netns"
    ];

    iptables.sandbox.method = "landlock";
    iptables.sandbox.net = "all";
    iptables.sandbox.capabilities = [ "net_admin" ];

    # iputils provides `ping` (and arping, clockdiff, tracepath)
    iputils.sandbox.method = "landlock";
    iputils.sandbox.net = "all";
    iputils.sandbox.capabilities = [ "net_raw" ];

    iw.sandbox.method = "landlock";
    iw.sandbox.net = "all";
    iw.sandbox.capabilities = [ "net_admin" ];

    jq.sandbox.method = "bwrap";
    jq.sandbox.autodetectCliPaths = "existingFile";

    killall.sandbox.method = "landlock";
    killall.sandbox.extraPaths = [
      "/proc"
    ];

    krita.sandbox.method = "bwrap";
    krita.sandbox.whitelistWayland = true;
    krita.sandbox.autodetectCliPaths = "existing";
    krita.sandbox.extraHomePaths = [
      "dev"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "ref"
      "tmp"
    ];

    libcap_ng.sandbox.enable = false;  # there's something about /proc/$pid/fd which breaks `readlink`/stat with every sandbox technique (except capsh-only)

    libnotify.sandbox.method = "bwrap";
    libnotify.sandbox.whitelistDbus = [ "user" ];  # notify-send

    losslesscut-bin.sandbox.method = "bwrap";
    losslesscut-bin.sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # videos from e.g. mobile phone
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    losslesscut-bin.sandbox.whitelistAudio = true;
    losslesscut-bin.sandbox.whitelistDri = true;
    losslesscut-bin.sandbox.whitelistWayland = true;
    losslesscut-bin.sandbox.whitelistX = true;

    lsof.sandbox.method = "capshonly";  # lsof doesn't sandbox under bwrap or even landlock w/ full access to /
    lsof.sandbox.capabilities = [ "dac_override" "sys_ptrace" ];

    lua = {};

    mercurial.sandbox.method = "bwrap";  # TODO:sandbox: untested
    mercurial.sandbox.net = "clearnet";
    mercurial.sandbox.whitelistPwd = true;

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];
    monero-gui.sandbox.method = "bwrap";
    monero-gui.sandbox.net = "all";
    monero-gui.sandbox.extraHomePaths = [
      "records/finance/cryptocurrencies/monero"
    ];

    mumble.persist.byStore.private = [ ".local/share/Mumble" ];

    nano.sandbox.method = "bwrap";
    nano.sandbox.autodetectCliPaths = "existingFileOrParent";

    netcat.sandbox.method = "landlock";
    netcat.sandbox.net = "all";

    nethogs.sandbox.method = "capshonly";  # *partially* works under landlock w/ full access to /
    nethogs.sandbox.capabilities = [ "net_admin" "net_raw" ];

    # provides `arp`, `hostname`, `route`, `ifconfig`
    nettools.sandbox.method = "landlock";
    nettools.sandbox.net = "all";
    nettools.sandbox.capabilities = [ "net_admin" "net_raw" ];
    nettools.sandbox.extraPaths = [
      "/proc"
    ];

    networkmanagerapplet.sandbox.method = "bwrap";
    networkmanagerapplet.sandbox.whitelistWayland = true;
    networkmanagerapplet.sandbox.whitelistDbus = [ "system" ];

    nixpkgs-review.sandbox.method = "bwrap";
    nixpkgs-review.sandbox.wrapperType = "inplace";  #< shell completions use full paths
    nixpkgs-review.sandbox.net = "clearnet";
    nixpkgs-review.sandbox.whitelistPwd = true;
    nixpkgs-review.sandbox.extraPaths = [
      "/nix"
    ];

    nmap.sandbox.method = "bwrap";
    nmap.sandbox.net = "all";  # clearnet and lan

    nmon.sandbox.method = "landlock";
    nmon.sandbox.extraPaths = [
      "/proc"
    ];

    nodejs = {};

    # `nvme list` only shows results when run as root.
    nvme-cli.sandbox.method = "landlock";
    nvme-cli.sandbox.extraPaths = [
      "/sys/devices"
      "/sys/class/nvme"
      "/sys/class/nvme-subsystem"
      "/sys/class/nvme-generic"
      "/dev"
    ];
    nvme-cli.sandbox.capabilities = [ "sys_rawio" ];

    # contains only `oathtool`, which i only use for evaluating TOTP codes from CLI/stdin
    oath-toolkit.sandbox.method = "bwrap";

    # settings (electron app)
    obsidian.persist.byStore.plaintext = [ ".config/obsidian" ];

    parted.sandbox.method = "landlock";
    parted.sandbox.extraPaths = [
      "/dev"
    ];
    parted.sandbox.autodetectCliPaths = "existing";  #< sometimes you'll use parted on a device file.

    patchelf = {};

    pavucontrol.sandbox.method = "bwrap";
    pavucontrol.sandbox.whitelistAudio = true;
    pavucontrol.sandbox.whitelistWayland = true;

    pciutils.sandbox.method = "landlock";
    pciutils.sandbox.extraPaths = [
      "/sys/bus/pci"
      "/sys/devices"
    ];

    "perlPackages.FileMimeInfo".sandbox.enable = false;  #< TODO: sandbox `mimetype` but not `mimeopen`.

    powertop.sandbox.method = "landlock";
    powertop.sandbox.capabilities = [ "ipc_lock" "sys_admin" ];
    powertop.sandbox.extraPaths = [
      "/proc"
      "/sys/class"
      "/sys/devices"
      "/sys/kernel"
    ];

    # procps: free, pgrep, pidof, pkill, ps, pwait, top, uptime, couple others
    procps.sandbox.method = "bwrap";
    procps.sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"
    ];

    pstree.sandbox.method = "landlock";
    pstree.sandbox.extraPaths = [
      "/proc"
    ];

    pulseaudio = {};

    pulsemixer.sandbox.method = "landlock";
    pulsemixer.sandbox.whitelistAudio = true;

    pwvucontrol.sandbox.method = "bwrap";
    pwvucontrol.sandbox.whitelistAudio = true;
    pwvucontrol.sandbox.whitelistDri = true;  # else perf on moby is unusable
    pwvucontrol.sandbox.whitelistWayland = true;

    python3-repl.packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      requests
    ]);
    python3-repl.sandbox.method = "bwrap";
    python3-repl.sandbox.net = "clearnet";
    python3-repl.sandbox.extraHomePaths = [
      "/"
      ".persist/plaintext"
    ];

    qemu.sandbox.enable = false;  #< it's a launcher
    qemu.buildCost = 1;

    rsync.sandbox.method = "bwrap";
    rsync.sandbox.net = "clearnet";
    rsync.sandbox.autodetectCliPaths = "existingOrParent";

    rustc = {};

    sane-open-desktop.sandbox.enable = false;  #< trivial script, and all our deps are sandboxed
    sane-open-desktop.suggestedPrograms = [
      "gdbus"
    ];

    screen.sandbox.enable = false;  #< tty; needs to run anything

    sequoia.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sequoia.sandbox.whitelistPwd = true;
    sequoia.sandbox.autodetectCliPaths = true;

    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];
    shattered-pixel-dungeon.sandbox.method = "bwrap";
    shattered-pixel-dungeon.sandbox.whitelistAudio = true;
    shattered-pixel-dungeon.sandbox.whitelistDri = true;
    shattered-pixel-dungeon.sandbox.whitelistWayland = true;

    # printer/filament settings
    slic3r.persist.byStore.plaintext = [ ".Slic3r" ];

    slurp.sandbox.method = "bwrap";
    slurp.sandbox.whitelistWayland = true;

    # use like `sudo smartctl /dev/sda -a`
    smartmontools.sandbox.method = "landlock";
    smartmontools.sandbox.wrapperType = "inplace";  # ships a script in /etc that calls into its bin
    smartmontools.sandbox.autodetectCliPaths = "existing";
    smartmontools.sandbox.capabilities = [ "sys_rawio" ];

    sops.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sops.sandbox.extraHomePaths = [
      ".config/sops"
      "dev/nixos"
      # TODO: sops should only need access to knowledge/secrets,
      # except that i currently put its .sops.yaml config in the root of ~/knowledge
      "knowledge"
    ];

    soundconverter.sandbox.method = "bwrap";
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
    soundconverter.sandbox.autodetectCliPaths = "existingOrParent";

    sox.sandbox.method = "bwrap";
    sox.sandbox.autodetectCliPaths = "existingFileOrParent";
    sox.sandbox.whitelistAudio = true;

    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];
    space-cadet-pinball.sandbox.method = "bwrap";
    space-cadet-pinball.sandbox.whitelistAudio = true;
    space-cadet-pinball.sandbox.whitelistDri = true;
    space-cadet-pinball.sandbox.whitelistWayland = true;

    speedtest-cli.sandbox.method = "bwrap";
    speedtest-cli.sandbox.net = "all";

    sqlite = {};

    sshfs-fuse = {};  # used by fs.nix

    strace.sandbox.enable = false;  #< needs to `exec` its args, and therefore support *anything*

    subversion.sandbox.method = "bwrap";
    subversion.sandbox.net = "clearnet";
    subversion.sandbox.whitelistPwd = true;
    sudo.sandbox.enable = false;

    superTux.sandbox.method = "bwrap";
    superTux.sandbox.wrapperType = "inplace";  # package Makefile incorrectly installs to $out/games/superTux instead of $out/share/games
    superTux.sandbox.whitelistAudio = true;
    superTux.sandbox.whitelistDri = true;
    superTux.sandbox.whitelistWayland = true;
    superTux.persist.byStore.plaintext = [ ".local/share/supertux2" ];

    swappy.sandbox.method = "bwrap";
    swappy.sandbox.autodetectCliPaths = "existingFileOrParent";
    swappy.sandbox.whitelistWayland = true;

    tcpdump.sandbox.method = "landlock";
    tcpdump.sandbox.net = "all";
    tcpdump.sandbox.autodetectCliPaths = "existingFileOrParent";
    tcpdump.sandbox.capabilities = [ "net_admin" "net_raw" ];

    tdesktop.persist.byStore.private = [ ".local/share/TelegramDesktop" ];

    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    tree.sandbox.method = "landlock";
    tree.sandbox.autodetectCliPaths = true;
    tree.sandbox.whitelistPwd = true;

    tumiki-fighters.sandbox.method = "bwrap";
    tumiki-fighters.sandbox.whitelistAudio = true;
    tumiki-fighters.sandbox.whitelistDri = true;  #< not strictly necessary, but triples CPU perf
    tumiki-fighters.sandbox.whitelistWayland = true;
    tumiki-fighters.sandbox.whitelistX = true;

    util-linux.sandbox.enable = false;  #< TODO: possible to sandbox if i specific a different profile for each of its ~50 binaries

    unzip.sandbox.method = "bwrap";
    unzip.sandbox.autodetectCliPaths = "existingOrParent";
    unzip.sandbox.whitelistPwd = true;

    usbutils.sandbox.method = "bwrap";  # breaks `usbhid-dump`, but `lsusb`, `usb-devices` work
    usbutils.sandbox.extraPaths = [
      "/sys/devices"
      "/sys/bus/usb"
    ];

    valgrind = {};

    visidata.sandbox.method = "bwrap";  # TODO:sandbox: untested
    visidata.sandbox.autodetectCliPaths = true;

    # `vulkaninfo`, `vkcube`
    vulkan-tools.sandbox.method = "landlock";

    vvvvvv.sandbox.method = "bwrap";
    vvvvvv.sandbox.whitelistAudio = true;
    vvvvvv.sandbox.whitelistDri = true;  #< playable without, but burns noticably more CPU
    vvvvvv.sandbox.whitelistWayland = true;
    vvvvvv.persist.byStore.plaintext = [ ".local/share/VVVVVV" ];

    w3m.sandbox.method = "bwrap";
    w3m.sandbox.net = "all";
    w3m.sandbox.extraHomePaths = [
      # little-used feature, but you can save web pages :)
      "tmp"
    ];

    wdisplays.sandbox.method = "bwrap";
    wdisplays.sandbox.whitelistWayland = true;

    wget.sandbox.method = "bwrap";
    wget.sandbox.net = "all";
    wget.sandbox.whitelistPwd = true;  # saves to pwd by default

    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    # `wg`, `wg-quick`
    wireguard-tools.sandbox.method = "landlock";
    wireguard-tools.sandbox.capabilities = [ "net_admin" ];

    # provides `iwconfig`, `iwlist`, `iwpriv`, ...
    wirelesstools.sandbox.method = "landlock";
    wirelesstools.sandbox.capabilities = [ "net_admin" ];

    wl-clipboard.sandbox.method = "bwrap";
    wl-clipboard.sandbox.whitelistWayland = true;

    wtype = {};

    xwayland.sandbox.method = "bwrap";
    xwayland.sandbox.wrapperType = "inplace";  #< consumers use it as a library (e.g. wlroots)
    xwayland.sandbox.whitelistWayland = true;  #< just assuming this is needed
    xwayland.sandbox.whitelistX = true;
    xwayland.sandbox.whitelistDri = true;  #< would assume this gives better gfx perf

    xterm.sandbox.enable = false;  # need to be able to do everything

    yarn.persist.byStore.plaintext = [ ".cache/yarn" ];

    yt-dlp.sandbox.method = "bwrap";  # TODO:sandbox: untested
    yt-dlp.sandbox.net = "all";
    yt-dlp.sandbox.whitelistPwd = true;  # saves to pwd by default

    zfs = {};
  };

  programs.feedbackd = lib.mkIf config.sane.programs.feedbackd.enabled {
    enable = true;
  };
}
