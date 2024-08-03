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
      "ausyscall"
      "bridge-utils"  # for brctl; debug linux "bridge" inet devices
      "btrfs-progs"
      "cacert.unbundled"  # some services require unbundled /etc/ssl/certs
      "cryptsetup"
      "curl"
      "ddrescue"
      "dig"
      "dtc"  # device tree [de]compiler
      "e2fsprogs"  # resize2fs
      "efibootmgr"
      "errno"
      "ethtool"
      "fatresize"
      "fd"
      "file"
      "forkstat"  # monitor every spawned/forked process
      "free"
      # "fwupd"
      "gawk"
      "gdb"  # to debug segfaults
      "git"
      "gptfdisk"  # gdisk
      "hdparm"
      "hping"
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
      "libcap_ng"  # for `netcap`, `pscap`, `captest`
      "lsof"
      "man-pages"
      "man-pages-posix"
      # "miniupnpc"
      "mmcli"
      "nano"
      #  "ncdu"  # ncurses disk usage. doesn't cross compile (zig)
      "neovim"
      "netcat"
      "nethogs"
      "nix"
      "nmap"
      "nmcli"
      "nvme-cli"  # nvme
      # "openssl"
      "parted"
      "pciutils"
      "powertop"
      "ps"
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
      "watch"
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
      "exiftool"
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
      # "python3.pkgs.eyeD3"  # music tagging
      "ripgrep"  # needed as a user package so that its user-level config file can be installed
      "rsync"
      "rsyslog"  # KEEP THIS HERE if you want persistent logging
      "sane-deadlines"
      "sane-scripts.bittorrent"
      "sane-scripts.cli"
      "sane-secrets-unlock"
      "sane-sysload"
      "sc-im"
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
      "qmk-udev-rules"
      "sane-scripts.dev"
      "sequoia"
      # "via"
      "wally-cli"
      # "zsa-udev-rules"
    ];

    consoleMediaUtils = declPackageSet [
      "blast-ugjka"  # cast audio to UPNP/DLNA devices (via pulseaudio sink)
      # "catt"  # cast videos to chromecast
      "ffmpeg"
      "go2tv"  # cast videos to UPNP/DLNA device (i.e. tv).
      "imagemagick"
      "sane-cast"  # cast videos to UPNP/DLNA, with compatibility
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

    gameApps = declPackageSet [
      "animatch"
      "gnome-2048"
      "gnome.hitori"  # like sudoku
    ];

    pcGameApps = declPackageSet [
      # "andyetitmoves" # TODO: fix build!
      # "armagetronad"  # tron/lightcycles; WAN and LAN multiplayer
      "celeste64"
      # "cutemaze"      # meh: trivial maze game; qt6 and keyboard-only
      # "cuyo"          # trivial puyo-puyo clone
      "endless-sky"     # space merchantilism/exploration
      # "factorio"
      "frozen-bubble"   # WAN + LAN + 1P/2P bubble bobble
      "hase"            # WAN worms game
      # "hedgewars"     # WAN + LAN worms game (5~10 people online at any moment; <https://hedgewars.org>)
      # "libremines"    # meh: trivial minesweeper; qt6
      # "mario0"        # SMB + portal
      # "mindustry"
      # "minesweep-rs"  # CLI minesweeper
      # "nethack"
      # "osu-lazer"
      # "pinball"       # 3d pinball; kb/mouse. old sourceforge project
      # "powermanga"    # STYLISH space invaders derivative (keyboard-only)
      "shattered-pixel-dungeon"  # doesn't cross compile
      "space-cadet-pinball"  # LMB/RMB controls (bindable though. volume buttons?)
      "steam"
      "superTux"  # keyboard-only controls
      "superTuxKart"  # poor FPS on pinephone
      "tumiki-fighters" # keyboard-only
      "vvvvvv"  # keyboard-only controls
      # "wine"
    ];

    guiApps = declPackageSet [
      # package sets
      "gameApps"
      "guiBaseApps"
    ];

    guiBaseApps = declPackageSet [
      # "abaddon"  # discord client
      "alacritty"  # terminal emulator
      "calls"  # gnome calls (dialer/handler)
      "dbus"
      "dconf"  # required by many packages, but not well-documented :(
      # "delfin"  # Jellyfin client
      "dialect"  # language translation
      "dino"  # XMPP client
      "dissent"  # Discord client (formerly known as: gtkcord4)
      # "emote"
      # "evince"  # PDF viewer
      # "flare-signal"  # gtk4 signal client
      # "foliate"  # e-book reader
      "fractal"  # matrix client
      "g4music"  # local music player
      # "gnome.cheese"
      # "gnome-feeds"  # RSS reader (with claimed mobile support)
      # "gnome.file-roller"
      "geary"  # adaptive e-mail client; uses webkitgtk 4.1
      "gnome-calculator"
      "gnome-calendar"
      "gnome.gnome-clocks"
      "gnome.gnome-maps"
      # "gnome-podcasts"
      # "gnome.gnome-system-monitor"
      # "gnome.gnome-terminal"  # works on phosh
      "gnome.gnome-weather"
      # "seahorse"  # keyring/secret manager
      "gnome-frog"  # OCR/QR decoder
      "gpodder"
      # "gst-device-monitor"  # for debugging audio/video
      # "gthumb"
      # "lemoa"  # lemmy app
      # "libcamera"  # for `cam` binary (useful for debugging cameras)
      "libnotify"  # for notify-send; debugging
      # "lollypop"
      "loupe"  # image viewer
      "mate.engrampa"  # archive manager
      "mepo"  # maps viewer
      # "mesa-demos"  # for eglinfo, glxinfo & other testing tools
      "mpv"
      "networkmanagerapplet"  # for nm-connection-editor: it's better than not having any gui!
      "ntfy-sh"  # notification service
      # "newsflash"  # RSS viewer
      "pavucontrol"
      "pwvucontrol"  # pipewire version of pavu
      # "picard"  # music tagging
      # "libsForQt5.plasmatube"  # Youtube player
      "signal-desktop"
      # "snapshot"  # camera app
      "spot"  # Gnome Spotify client
      # "sublime-music"
      # "tdesktop"  # broken on phosh
      # "tokodon"
      "tuba"  # mastodon/pleroma client (stores pw in keyring)
      "vulkan-tools"  # vulkaninfo
      # "whalebird"  # pleroma client (Electron). input is broken on phosh.
      "xdg-terminal-exec"
      "youtube-tui"
      "zathura"  # PDF/CBZ/ePUB viewer
    ];

    handheldGuiApps = declPackageSet [
      # "celluloid"  # mpv frontend
      # "chatty"  # matrix/xmpp/irc client  (2023/12/29: disabled because broken cross build)
      # "cozy"  # audiobook player
      "epiphany"  # gnome's web browser
      # "iotas"  # note taking app
      "komikku"
      "koreader"
      "lgtrombetta-compass"
      "megapixels"  # camera app
      "notejot"  # note taking, e.g. shopping list
      "planify"  # todo-tracker/planner
      "portfolio-filemanager"
      "tangram"  # web browser
      "wike"  # Wikipedia Reader
      "xarchiver"  # archiver, backup option for when engrampa UI overflows screen and is unusale (xarchiver UI fails in different ways)
    ];

    pcGuiApps = declPackageSet [
      # package sets
      "pcGameApps"
      "pcTuiApps"
      ####
      "audacity"
      # "blanket"  # ambient noise generator
      "brave"  # for the integrated wallet -- as a backup
      # "cantata"  # music player (mpd frontend)
      # "chromium"  # chromium takes hours to build. brave is chromium-based, distributed in binary form, so prefer it.
      # "cups"
      "discord"  # x86-only
      # "electrum"
      "element-desktop"
      "firefox"
      "font-manager"
      # "gajim"  # XMPP client. cross build tries to import host gobject-introspection types (2023/09/01)
      "gimp"  # broken on phosh
      # "gnome.dconf-editor"
      # "gnome.file-roller"
      "gnome-disk-utility"
      "nautilus"  # file browser
      # "gnome.totem"  # video player, supposedly supports UPnP
      # "handbrake"  #< TODO: fix build
      "inkscape"
      # "jellyfin-media-player"
      "kdenlive"
      # "keymapp"
      # "kid3"  # audio tagging
      "krita"
      "libreoffice"  # TODO: replace with an office suite that uses saner packaging?
      "losslesscut-bin"  # x86-only
      # "makemkv"  # x86-only
      # "monero-gui"  # x86-only
      # "mumble"
      # "nheko"  # Matrix chat client
      "nicotine-plus"  # soulseek client
      # "obsidian"
      # "openscad"  # 3d modeling
      # "rhythmbox"  # local music player
      # "slic3r"
      "soundconverter"
      "spotify"  # x86-only
      "tor-browser"  # x86-only
      # "vlc"
      "wireshark"  # could maybe ship the cli as sysadmin pkg
      # "xterm"  # requires Xwayland
      # "zecwallet-lite"  # x86-only
      # "zulip"
    ];


    # INDIVIDUAL PACKAGE DEFINITIONS

    alsaUtils.sandbox.method = "landlock";
    alsaUtils.sandbox.whitelistAudio = true;  #< not strictly necessary?

    backblaze-b2 = {};

    blanket.buildCost = 1;
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

    btrfs-progs.sandbox.method = "bwrap";  #< bwrap, landlock: both work
    btrfs-progs.sandbox.autodetectCliPaths = "existing";  # e.g. `btrfs filesystem df /my/fs`

    "cacert.unbundled".sandbox.enable = false;

    cargo.persist.byStore.plaintext = [ ".cargo" ];

    clang = {};

    clightning-sane.sandbox.method = "bwrap";
    clightning-sane.sandbox.extraPaths = [
      "/var/lib/clightning/bitcoin/lightning-rpc"
    ];

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

    delfin.buildCost = 1;
    delfin.sandbox.method = "bwrap";
    delfin.sandbox.whitelistAudio = true;
    delfin.sandbox.whitelistDbus = [ "user" ];  # else `mpris` plugin crashes the player
    delfin.sandbox.whitelistDri = true;
    delfin.sandbox.whitelistWayland = true;
    delfin.sandbox.net = "clearnet";
    # auth token, preferences
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
    dtc.sandbox.autodetectCliPaths = "existingFile";  # TODO:sandbox: untested

    duplicity = {};

    e2fsprogs.sandbox.method = "landlock";
    e2fsprogs.sandbox.autodetectCliPaths = "existing";

    efibootmgr.sandbox.method = "landlock";
    efibootmgr.sandbox.extraPaths = [
      "/sys/firmware/efi"
    ];

    eg25-control = {};

    electrum.buildCost = 1;
    electrum.sandbox.method = "bwrap";  # TODO:sandbox: untested
    electrum.sandbox.net = "all";  # TODO: probably want to make this run behind a VPN, always
    electrum.sandbox.whitelistWayland = true;
    electrum.persist.byStore.ephemeral = [ ".electrum" ];  #< TODO: use XDG dirs!

    endless-sky.buildCost = 1;
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
    # bwrap causes `/proc` files to be listed differently (e.g. `eza /proc/sys/net/ipv6/conf/`)
    # bwrap loses group info (so files owned by other users appear as owner "nobody")
    eza.sandbox.method = "landlock";
    # eza.sandbox.method = "bwrap";
    eza.sandbox.autodetectCliPaths = "existing";
    eza.sandbox.whitelistPwd = true;
    eza.sandbox.extraHomePaths = [
      # so that e.g. `eza -l ~` can show which symlink exist
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    fatresize.sandbox.method = "landlock";
    fatresize.sandbox.autodetectCliPaths = "parent";  # /dev/sda1 -> needs /dev/sda

    fd.sandbox.method = "landlock";
    fd.sandbox.autodetectCliPaths = "existing";
    fd.sandbox.whitelistPwd = true;
    fd.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    ffmpeg.buildCost = 1;
    ffmpeg.sandbox.method = "bwrap";
    ffmpeg.sandbox.autodetectCliPaths = "existingFileOrParent";  # it outputs uncreated files -> parent dir needs mounting

    file.sandbox.method = "bwrap";
    file.sandbox.autodetectCliPaths = "existing";  #< file OR directory, yes

    findutils.sandbox.method = "bwrap";
    findutils.sandbox.autodetectCliPaths = "existing";
    findutils.sandbox.whitelistPwd = true;
    findutils.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    fluffychat-moby.persist.byStore.plaintext = [ ".local/share/chat.fluffy.fluffychat" ];

    font-manager.buildCost = 1;
    font-manager.sandbox.method = "bwrap";
    font-manager.sandbox.whitelistWayland = true;
    font-manager.packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.font-manager.override {
      # build without the "Google Fonts" integration feature, to save closure / avoid webkitgtk_4_0
      withWebkit = false;
    });

    forkstat.sandbox.method = "landlock";  #< doesn't seem to support bwrap
    forkstat.sandbox.isolatePids = false;
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
    gawk.sandbox.autodetectCliPaths = "existingFile";

    geoclue2-with-demo-agent = {};

    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    gh.persist.byStore.private = [ ".config/gh" ];

    gimp.buildCost = 1;
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

    gnome-calculator.buildCost = 1;
    gnome-calculator.sandbox.method = "bwrap";
    gnome-calculator.sandbox.whitelistWayland = true;

    gnome-calendar.buildCost = 1;
    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    gnome-calendar.sandbox.method = "bwrap";
    gnome-calendar.sandbox.whitelistWayland = true;

    # gnome-disks
    gnome-disk-utility.buildCost = 1;
    gnome-disk-utility.sandbox.method = "bwrap";
    gnome-disk-utility.sandbox.whitelistDbus = [ "system" ];
    gnome-disk-utility.sandbox.whitelistWayland = true;
    gnome-disk-utility.sandbox.extraHomePaths = [
      "tmp"
      "use/iso"
      # TODO: probably need /dev and such
    ];

    hping.sandbox.method = "landlock";
    hping.sandbox.net = "all";
    hping.sandbox.capabilities = [ "net_raw" ];
    hping.sandbox.autodetectCliPaths = "existingFile";  # for sending packet data from file

    # seahorse: dump gnome-keyring secrets.
    seahorse.buildCost = 1;
    # N.B. it can lso manage ~/.ssh keys, but i explicitly don't add those to the sandbox for now.
    seahorse.sandbox.method = "bwrap";
    seahorse.sandbox.whitelistDbus = [ "user" ];
    seahorse.sandbox.whitelistWayland = true;

    gnome-2048.buildCost = 1;
    gnome-2048.sandbox.method = "bwrap";
    gnome-2048.sandbox.whitelistWayland = true;
    gnome-2048.persist.byStore.plaintext = [ ".local/share/gnome-2048/scores" ];

    gnome-frog.buildCost = 1;
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
    gnome-frog.persist.byStore.ephemeral = [
      ".local/share/tessdata"  # 15M; dunno what all it is.
    ];

    # hitori rules:
    # - click to shade a tile
    # 1. no number may appear unshaded more than once in the same row/column
    # 2. no two shaded tiles can be direct N/S/E/W neighbors
    # - win once (1) and (2) are satisfied
    "gnome.hitori".buildCost = 1;
    "gnome.hitori".sandbox.method = "bwrap";
    "gnome.hitori".sandbox.whitelistWayland = true;

    gnugrep.sandbox.method = "bwrap";
    gnugrep.sandbox.autodetectCliPaths = "existing";
    gnugrep.sandbox.whitelistPwd = true;
    gnugrep.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

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

    hase.buildCost = 1;
    hase.sandbox.method = "bwrap";
    hase.sandbox.net = "clearnet";
    hase.sandbox.whitelistAudio = true;
    hase.sandbox.whitelistDri = true;
    hase.sandbox.whitelistWayland = true;

    # hdparm: has to be run as sudo. e.g. `sudo hdparm -i /dev/sda`
    hdparm.sandbox.method = "bwrap";
    hdparm.sandbox.autodetectCliPaths = "existingFile";

    host.sandbox.method = "landlock";
    host.sandbox.net = "all";  #< technically, only needs to contact localhost's DNS server

    iftop.sandbox.method = "landlock";
    iftop.sandbox.capabilities = [ "net_raw" ];

    # inetutils: ping, ifconfig, hostname, traceroute, whois, ....
    # N.B.: inetutils' `ping` is shadowed by iputils' ping (by nixos, intentionally).
    inetutils.sandbox.method = "landlock";  # want to keep the same netns, at least.

    inkscape.buildCost = 1;
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

    # provides `ip`, `routel`, `bridge`, others.
    # landlock works fine for most of these, but `ip netns exec` wants to attach to an existing namespace
    # and that means we can't use ANY sandboxer for it.
    iproute2.sandbox.enable = false;
    # iproute2.sandbox.net = "all";
    # iproute2.sandbox.capabilities = [ "net_admin" ];
    # iproute2.sandbox.extraPaths = [
    #   "/run/netns"  # for `ip netns ...` to work, but maybe not needed anymore?
    #   "/sys/class/net"  # for `ip netns ...` to work
    #   "/var/run/netns"
    # ];

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

    krita.buildCost = 1;
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

    libcamera = {};

    libcap.sandbox.enable = false;  #< for `capsh`, which i use as a sandboxer
    libcap_ng.sandbox.enable = false;  # there's something about /proc/$pid/fd which breaks `readlink`/stat with every sandbox technique (except capsh-only)

    libnotify.sandbox.method = "bwrap";
    libnotify.sandbox.whitelistDbus = [ "user" ];  # notify-send

    lightning-cli.packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.clightning "lightning-cli";
    lightning-cli.sandbox.method = "bwrap";
    lightning-cli.sandbox.extraHomePaths = [
      ".lightning/bitcoin/lightning-rpc"
    ];
    # `lightning-cli` finds its RPC file via `~/.lightning/bitcoin/lightning-rpc`, to message the daemon
    lightning-cli.fs.".lightning".symlink.target = "/var/lib/clightning";

    losslesscut-bin.buildCost = 1;
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

    man-pages.sandbox.enable = false;
    man-pages-posix.sandbox.enable = false;

    mercurial.sandbox.method = "bwrap";  # TODO:sandbox: untested
    mercurial.sandbox.net = "clearnet";
    mercurial.sandbox.whitelistPwd = true;

    mesa-demos.sandbox.method = "bwrap";
    mesa-demos.sandbox.whitelistDri = true;
    mesa-demos.sandbox.whitelistWayland = true;
    mesa-demos.sandbox.whitelistX = true;

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    monero-gui.buildCost = 1;
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];
    monero-gui.sandbox.method = "bwrap";
    monero-gui.sandbox.net = "all";
    monero-gui.sandbox.extraHomePaths = [
      "records/finance/cryptocurrencies/monero"
    ];

    mumble.buildCost = 1;
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
    nixpkgs-review.sandbox.extraHomePaths = [
      ".config/git"  #< it needs to know commiter name/email, even if not posting
    ];
    nixpkgs-review.sandbox.extraPaths = [
      "/nix"
    ];
    nixpkgs-review.persist.byStore.ephemeral = [
      ".cache/nixpkgs-review"  #< help it not exhaust / tmpfs
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

    passt.sandbox.enable = false;  #< sandbox helper (netns specifically)

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

    "perlPackages.FileMimeInfo" = {};

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
    procps.sandbox.isolatePids = false;

    pstree.sandbox.method = "landlock";
    pstree.sandbox.extraPaths = [
      "/proc"
    ];

    pulseaudio = {};

    pulsemixer.sandbox.method = "landlock";
    pulsemixer.sandbox.whitelistAudio = true;

    pwvucontrol.buildCost = 1;
    pwvucontrol.sandbox.method = "bwrap";
    pwvucontrol.sandbox.whitelistAudio = true;
    pwvucontrol.sandbox.whitelistDri = true;  # else perf on moby is unusable
    pwvucontrol.sandbox.whitelistWayland = true;

    python3-repl.packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      psutil
      pykakasi
      requests
      unidecode
    ]);
    python3-repl.sandbox.method = "bwrap";
    python3-repl.sandbox.net = "clearnet";
    python3-repl.sandbox.extraHomePaths = [
      "/"
      ".persist/plaintext"
    ];

    qemu.sandbox.enable = false;  #< it's a launcher
    qemu.buildCost = 2;

    rsync.sandbox.method = "bwrap";
    rsync.sandbox.net = "clearnet";
    rsync.sandbox.autodetectCliPaths = "existingOrParent";

    rustc = {};

    sane-cast.sandbox.method = "bwrap";
    sane-cast.sandbox.net = "clearnet";
    sane-cast.sandbox.autodetectCliPaths = "existingFile";
    sane-cast.suggestedPrograms = [ "go2tv" ];

    sane-die-with-parent.sandbox.enable = false;  #< it's a launcher; can't sandbox

    sane-weather.sandbox.method = "bwrap";
    sane-weather.sandbox.net = "clearnet";

    sc-im.sandbox.method = "bwrap";
    sc-im.sandbox.autodetectCliPaths = "existingFile";

    screen.sandbox.enable = false;  #< tty; needs to run anything

    sequoia.packageUnwrapped = pkgs.sequoia.overrideAttrs (_: {
      # XXX(2024-07-30): sq_autocrypt_import test failure: "Warning: 9B7DD433F254904A is expired."
      doCheck = false;
    });
    sequoia.buildCost = 1;
    sequoia.sandbox.method = "bwrap";
    sequoia.sandbox.whitelistPwd = true;
    sequoia.sandbox.autodetectCliPaths = "existingFileOrParent";  # supports `-o <file-to-create>`

    shattered-pixel-dungeon.buildCost = 1;
    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];
    shattered-pixel-dungeon.sandbox.method = "bwrap";
    shattered-pixel-dungeon.sandbox.whitelistAudio = true;
    shattered-pixel-dungeon.sandbox.whitelistDri = true;
    shattered-pixel-dungeon.sandbox.whitelistWayland = true;

    # printer/filament settings
    slic3r.buildCost = 1;
    slic3r.persist.byStore.plaintext = [ ".Slic3r" ];

    slurp.sandbox.method = "bwrap";
    slurp.sandbox.whitelistWayland = true;

    # use like `sudo smartctl /dev/sda -a`
    smartmontools.sandbox.method = "landlock";
    smartmontools.sandbox.wrapperType = "inplace";  # ships a script in /etc that calls into its bin
    smartmontools.sandbox.autodetectCliPaths = "existing";
    smartmontools.sandbox.capabilities = [ "sys_rawio" ];

    # snapshot camera, based on libcamera
    # TODO: enable dma heaps for more efficient buffer sharing: <https://gitlab.com/postmarketOS/pmaports/-/issues/2789>
    snapshot = {};

    sops.sandbox.method = "bwrap";  # TODO:sandbox: untested
    sops.sandbox.extraHomePaths = [
      ".config/sops"
      "nixos"
      # TODO: sops should only need access to knowledge/secrets,
      # except that i currently put its .sops.yaml config in the root of ~/knowledge
      "knowledge"
    ];

    soundconverter.buildCost = 1;
    soundconverter.sandbox.method = "bwrap";
    soundconverter.sandbox.whitelistWayland = true;
    soundconverter.sandbox.extraHomePaths = [
      "Music"
      "tmp"
      "use"
      ".config/dconf"
    ];
    soundconverter.sandbox.whitelistDbus = [ "user" ];  # for dconf
    soundconverter.sandbox.extraPaths = [
      "/mnt/servo/media/Music"
      "/mnt/servo/media/games"
    ];
    soundconverter.sandbox.autodetectCliPaths = "existingOrParent";

    sox.sandbox.method = "bwrap";
    sox.sandbox.autodetectCliPaths = "existingFileOrParent";
    sox.sandbox.whitelistAudio = true;

    space-cadet-pinball.buildCost = 1;
    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];
    space-cadet-pinball.sandbox.method = "bwrap";
    space-cadet-pinball.sandbox.whitelistAudio = true;
    space-cadet-pinball.sandbox.whitelistDri = true;
    space-cadet-pinball.sandbox.whitelistWayland = true;

    speedtest-cli.sandbox.method = "bwrap";
    speedtest-cli.sandbox.net = "all";

    sqlite = {};

    sshfs-fuse.sandbox.enable = true;  # used by fs.nix
    sshfs-fuse.sandbox.method = "bwrap";  #< N.B. if you call this from the CLI -- without `mount.fuse` -- set this to `none`
    sshfs-fuse.sandbox.net = "all";
    sshfs-fuse.sandbox.autodetectCliPaths = "parent";
    # sshfs-fuse.sandbox.extraPaths = [
    #   "/dev/fd"  # fuse.mount3 -o drop_privileges passes us data over /dev/fd/3
    #   "/mnt"  # XXX: not sure why i need all this, instead of just /mnt/desko, or /mnt/desko/home, etc
    # ];
    sshfs-fuse.sandbox.extraHomePaths = [
      ".ssh/id_ed25519"  #< TODO: add -o foo,bar=path/to/thing style arguments to autodetection
    ];

    strace.sandbox.enable = false;  #< needs to `exec` its args, and therefore support *anything*

    subversion.sandbox.method = "bwrap";
    subversion.sandbox.net = "clearnet";
    subversion.sandbox.whitelistPwd = true;
    sudo.sandbox.enable = false;

    superTux.buildCost = 1;
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

    tokodon.buildCost = 1;
    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    tree.sandbox.method = "landlock";
    tree.sandbox.autodetectCliPaths = "existing";
    tree.sandbox.whitelistPwd = true;

    tumiki-fighters.buildCost = 1;
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

    valgrind.buildCost = 1;
    valgrind.sandbox.enable = false;  #< it's a launcher: can't sandbox

    # `vulkaninfo`, `vkcube`
    vulkan-tools.sandbox.method = "landlock";

    vvvvvv.buildCost = 1;
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

    watch.sandbox.enable = false;  #< it executes the command it's given

    wdisplays.sandbox.method = "bwrap";
    wdisplays.sandbox.whitelistWayland = true;

    wget.sandbox.method = "bwrap";
    wget.sandbox.net = "all";
    wget.sandbox.whitelistPwd = true;  # saves to pwd by default

    whalebird.buildCost = 1;
    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    # `wg`, `wg-quick`
    wireguard-tools.sandbox.method = "landlock";
    wireguard-tools.sandbox.net = "all";
    wireguard-tools.sandbox.capabilities = [ "net_admin" ];

    # provides `iwconfig`, `iwlist`, `iwpriv`, ...
    wirelesstools.sandbox.method = "landlock";
    wirelesstools.sandbox.net = "all";
    wirelesstools.sandbox.capabilities = [ "net_admin" ];

    wl-clipboard.sandbox.method = "bwrap";
    wl-clipboard.sandbox.whitelistWayland = true;

    wtype = {};
    wtype.sandbox.method = "bwrap";
    wtype.sandbox.whitelistWayland = true;

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
  };

  sane.persist.sys.byStore.plaintext = lib.mkIf config.sane.programs.guiApps.enabled [
    # "/var/lib/alsa"                # preserve output levels, default devices
    { path = "/var/lib/systemd/backlight"; method = "bind"; }   # backlight brightness; bind because systemd T_T
  ];

  systemd.services."systemd-backlight@" = lib.mkIf config.sane.programs.guiApps.enabled {
    after = [
      "ensure-var-lib-systemd-backlight.service"
    ];
    wants = [
      "ensure-var-lib-systemd-backlight.service"
    ];
  };

  hardware.graphics = lib.mkIf config.sane.programs.guiApps.enabled ({
    enable = true;
  } // (lib.optionalAttrs pkgs.stdenv.isx86_64 {
    # for 32 bit applications
    # upstream nixpkgs forbids setting enable32Bit unless specifically x86_64 (so aarch64 isn't allowed)
    enable32Bit = lib.mkDefault true;
  }));

  system.activationScripts.notifyActive = lib.mkIf config.sane.programs.guiApps.enabled {
    text = lib.concatStringsSep "\n" ([
        ''
          tryNotifyUser() {
            local user="$1"
            local new_path="$PATH:/etc/profiles/per-user/$user/bin:${pkgs.sudo}/bin:${pkgs.libnotify}/bin"
            local version="$(cat $systemConfig/nixos-version)"
            PATH="$new_path" sudo -u "$user" \
              env PATH="$new_path" NIXOS_VERSION="$version" /bin/sh -c \
              '. $HOME/.profile; dbus_file="$XDG_RUNTIME_DIR/bus"; if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -e "$dbus_file" ]; then export DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_file"; fi ; if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then notify-send "nixos activated" "version: $NIXOS_VERSION" ; fi'
          }
        ''
      ] ++ lib.mapAttrsToList
        (user: en: lib.optionalString en "tryNotifyUser ${user} > /dev/null")
        config.sane.programs.guiApps.enableFor.user
    );
  };
}
