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
        ++ lib.optionals ((config.networking.wireless or {}).enable or false) [ "nixosBuiltinsWireless" ];
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
      "bandwhich"  # network/bandwidth monitor
      "bridge-utils"  # for brctl; debug linux "bridge" inet devices
      "btrfs-progs"
      "cacert.unbundled"  # some services require unbundled /etc/ssl/certs
      "captree"
      "cryptsetup"
      "curl"
      "ddrescue"
      "dig"
      "dmidecode"  # to query low-level hardware details like RAM modules
      "dtc"  # device tree [de]compiler
      "e2fsprogs"  # resize2fs
      "efibootmgr"
      "erdtree"  # like normal `tree` but colorful & prints sizes
      "errno"
      "ethtool"
      "evtest"
      "expect"
      "fatresize"
      "fd"
      "fftest"  # for debugging moby haptics/vibrator, mostly
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
      "htpasswd"
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
      "libgpiod"  # `gpiodetect`, `gpioinfo`, `gpiomon`, ...
      "libqmi"  # for `qmicli` modem control
      "lsof"
      "man-db"  # critical for `man -k` or `apropos` to work
      "man-pages"
      "man-pages-posix"
      # "miniupnpc"
      "mmcli"
      "nano"
      #  "ncdu"  # ncurses disk usage. doesn't cross compile (zig)
      "nfs-utils"  # required, for mounting nfs filesystems
      "neovim"
      "netcat"
      "nethogs"
      "nix"
      "nix-tree"
      "nmap"
      "nmcli"
      "nmon"
      # "nvimpager"
      "nvme-cli"  # nvme
      "openssl"
      "page"
      "parted"
      "pciutils"
      "picocom"  # serial TTY
      "powertop"
      "procs"  # a better `ps`
      "pstree"
      "ripgrep"
      "rsync"
      # "s6-rc"  # service manager
      # "screen"
      "see-cat"  # pretty-print equivalent to 'cat'
      "ssh"
      "sshpass"
      "smartmontools"  # smartctl
      "socat"
      "strace"
      "subversion"
      "tcpdump"
      "tree"
      "unixtools.ps"
      "unixtools.sysctl"
      "unixtools.xxd"
      "uptime"
      "usbutils"  # lsusb
      "util-linux"  # lsblk, lscpu, etc
      "valgrind"
      "watch"
      "wget"
      # "wirelesstools"  # iwlist
      # "xq"  # jq for XML
      # "zfs"  # doesn't cross-compile (requires samba)
    ];
    sysadminExtraUtils = declPackageSet [
      "sqlite"  # to debug sqlite3 databases
    ];

    # TODO: split these into smaller groups.
    # - moby doesn't want a lot of these.
    # - categories like
    #   - dev?
    #   - debugging?
    consoleUtils = declPackageSet [
      "alsa-utils"  # for aplay, speaker-test
      "bc"  # CLI calculator
      "cdecl"  # like <https://cdecl.org>. `cdecl explain 'struct foo *const inst'`
      # "cdrtools"
      # "clinfo"
      "colordiff"
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
      "hyperfine"  # benchmarking tool
      "lddtree"
      # "libsecret"  # for managing user keyrings (secret-tool)
      # "lm_sensors"  # for sensors-detect
      "lpac"  # for configuring eSIM profiles
      # "lshw"
      # "memtester"
      "mercurial"  # hg
      "mimeo"  # like xdg-open
      "mozlz4a"  # for extracting .mozlz4 files (firefox)
      "neovim"  # needed as a user package, for swap persistence
      "nix"  # needed as user package, for ~/.cache/nix persistence
      # "nettools"
      # "networkmanager"
      # "nvimpager"  # needed as a user package, for config.
      # "nixos-generators"
      # "node2nix"
      # "oathToolkit"  # for oathtool
      "objdump"
      "oils-for-unix"
      "page"  # needed as a user package, for config.
      "patchelf"
      # "ponymix"
      "pulsemixer"
      "python3-repl"
      # "python3.pkgs.eyeD3"  # music tagging
      "readline"  # for the config
      "ripgrep"  # needed as a user package so that its user-level config file can be installed
      # "rsyslog"  # KEEP THIS HERE if you want persistent logging (TODO: port to systemd, store in /var/log/...)
      "sane-deadlines"
      "sane-scripts.bittorrent"
      "sane-scripts.cli"
      "sane-secrets-unlock"
      "sane-sysload"
      "sc-im"  # CLI spreadsheet editor
      "snapper"
      "sops"  # for manually viewing secrets; outside `sane-secrets` (TODO: improve sane-secrets!)
      "speedtest-cli"
      "ssh"  # specified as a user program, to enable ssh-agent service
      "ssh-to-age" # used when provisioning a new nixos host
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
      "dasht"  # docset documentation viewer
      # "gh"  # MS GitHub cli
      "haredoc"
      "nix-check-deps"  # run `nix-check-deps packageName -f .` before submitting stuff upstream
      "nix-index"
      "nixfmt"  # run `nixfmt path/to/package.nix` before submitting stuff upstream
      "nixpkgs-hammering"
      "nixpkgs-review"
      "qmk-udev-rules"
      "sane-scripts.dev"
      "sequoia-sq"  # gpg tool
      # "via"
      "wally-cli"
      # "zsa-udev-rules"
    ];

    consoleMediaUtils = declPackageSet [
      # "catt"  # cast videos to chromecast
      # "sblast"  # cast audio to UPNP/DLNA devices (via pulseaudio sink)
      "ffmpeg"
      "go2tv"  # cast videos to UPNP/DLNA device (i.e. tv).
      "imagemagick"
      "sane-cast"  # cast videos to UPNP/DLNA, with compatibility
      "sox"
      "yt-dlp"
    ];

    pcTuiApps = declPackageSet [
      "aerc"  # email client
      # "cassini"  # Elegoo printer control. need here especially, for opening firewalls.
      # "mslicer"
      # "msmtp"  # sendmail
      # "offlineimap"  # email mailbox sync
      # "sfeed"  # RSS fetcher
      # "uvtools"
      "visidata"  # TUI spreadsheet viewer/editor
      "w3m"  # web browser
    ];

    devPkgs = declPackageSet [
      "cargo"
      "clang"
      "lua"
      "nodejs"
      "rustc"
      # "tree-sitter"
    ];

    gameApps = declPackageSet [
      "animatch"
      "gnome-2048"
      "hitori"  # like sudoku
      "quadrapassel"  # like tetris
    ];

    pcGameApps = declPackageSet [
      # "andyetitmoves" # TODO: fix build!
      # "armagetronad"  # tron/lightcycles; WAN and LAN multiplayer
      "celeste64"
      # "cutemaze"      # meh: trivial maze game; qt6 and keyboard-only
      # "cuyo"          # trivial puyo-puyo clone
      # "endless-sky"     # space merchantilism/exploration
      # "factorio"
      # "frozen-bubble"   # WAN + LAN + 1P/2P bubble bobble
      # "hase"            # WAN worms game
      # "hedgewars"     # WAN + LAN worms game (5~10 people online at any moment; <https://hedgewars.org>)
      # "libremines"    # meh: trivial minesweeper; qt6
      # "mario0"        # SMB + portal
      # "mindustry"
      # "minesweep-rs"  # CLI minesweeper
      # "nethack"
      # "osu-lazer"
      # "pinball"       # 3d pinball; kb/mouse. old sourceforge project
      # "powermanga"    # STYLISH space invaders derivative (keyboard-only)
      "puyovs"  # Puyo Puyo clone
      # "shattered-pixel-dungeon"  # doesn't cross compile
      # "sm64ex-coop"
      "sm64coopdx"
      "space-cadet-pinball"  # LMB/RMB controls (bindable though. volume buttons?)
      "steam"
      "superTux"  # keyboard-only controls
      "superTuxKart"  # poor FPS on pinephone
      # "tumiki-fighters" # keyboard-only
      "vvvvvv"  # keyboard-only controls
      # "wine"
      "zelda64recomp"
    ];

    guiApps = declPackageSet [
      # package sets
      "gameApps"
      "guiBaseApps"
    ];

    guiBaseApps = declPackageSet [
      # "abaddon"  # discord client
      "alacritty"  # terminal emulator
      "alpaca"  # ollama/LLM client
      "blanket"  # ambient noise generator
      "calls"  # gnome calls (dialer/handler)
      "confy"  # conference planning app
      "dbus"
      # "dconf"  # or use `gsettings`, with its keyfile backend
      # "delfin"  # Jellyfin client
      "dialect"  # language translation
      "dino"  # XMPP client
      "dissent"  # Discord client (formerly known as: gtkcord4)
      # "emote"
      # "envelope"  # GTK4 email client (alpha)
      # "evince"  # PDF viewer
      # "flare-signal"  # gtk4 signal client
      "fractal"  # matrix client
      # "g4music"  # local music player
      # "gnome.cheese"
      # "gnome-feeds"  # RSS reader (with claimed mobile support)
      # "gnome.file-roller"
      "geary"  # adaptive e-mail client; uses webkitgtk 4.1
      "gnome-calculator"
      "gnome-calendar"
      "gnome-clocks"
      "gnome-contacts"
      # "gnome-podcasts"
      # "gnome.gnome-system-monitor"
      # "gnome.gnome-terminal"  # works on phosh
      "gnome-frog"  # OCR/QR decoder
      "gnome-maps"
      "gnome-screenshot"  # libcamera-based screenshotter, for debugging; should be compatible with gc2145 camera on Pinephone
      "gnome-sound-recorder"  # a simple microphone recorder/tester
      "gnome-weather"
      "gpodder"
      "gsettings"
      "gst-device-monitor"  # for debugging audio/video
      "gst-launch"  # for debugging audio/video
      # "gthumb"
      # "lemoa"  # lemmy app
      "libcamera"  # for `cam` binary (useful for debugging cameras)
      "libnotify"  # for notify-send; debugging
      # "lollypop"
      "loupe"  # image viewer
      "lpa-gtk"  # eSIM profile manager (experimental)
      "mate.engrampa"  # archive manager
      "mepo"  # maps viewer
      # "mesa-demos"  # for eglinfo, glxinfo & other testing tools
      "mpv"
      "networkmanagerapplet"
      # "ntfy-sh"  # notification service
      "newelle"  # ollama/LLM client
      "newsflash"  # RSS viewer
      "papers"  # PDF viewer
      "pavucontrol"
      "powersupply"  # battery viewer
      "pwsp"  # PipeWire SoundPad -- used to inject noises into the mic
      "pwvucontrol"  # pipewire version of pavu
      # "picard"  # music tagging
      "resources"  # system monitor
      "sane-color-picker"
      # "seahorse"  # keyring/secret manager
      "signal-desktop"
      "snapshot"  # camera app
      # "spot"  # Gnome Spotify client
      # "sublime-music"
      # "tdesktop"  # broken on phosh
      # "tokodon"
      # "tuba"  # mastodon/pleroma client (stores pw in keyring)
      # "v4l-utils"  # for `media-ctl`; to debug cameras: <https://wiki.postmarketos.org/wiki/PINE64_PinePhone_(pine64-pinephone)#Cameras>
      "video-trimmer"
      "vulkan-tools"  # vulkaninfo
      # "whalebird"  # pleroma client (Electron). input is broken on phosh.
      "wiremix"  # wireplumber TUI
      "xdg-terminal-exec"
      "youtube-tui"
      # "zathura"  # PDF/CBZ/ePUB viewer
    ];

    handheldGuiApps = declPackageSet [
      # "celluloid"  # mpv frontend
      # "chatty"  # matrix/xmpp/irc client  (2023/12/29: disabled because broken cross build)
      # "cozy"  # audiobook player
      "epiphany"  # gnome's web browser
      "foliate"  # e-book reader
      # "iotas"  # note taking app
      "komikku"
      # "koreader"
      "lgtrombetta-compass"
      # "millipixels"  # camera app (libcamera, but does not support PPP as of 2024-11-29)
      "megapixels"  # camera app (does not support PPP as of 2024-11-29)
      "megapixels-next"  # camera app (which supports PPP, as of 2024-11-29)
      "notejot"  # note taking, e.g. shopping list
      # "planify"  # todo-tracker/planner  (XXX(2025-05-16): does not build; gxml tests fail against glib 2.84.1; planify itself fails still, if gxml.doCheck forced false)
      "portfolio-filemanager"
      # "tangram"  # web browser
      "wike"  # Wikipedia Reader
      "xarchiver"  # archiver, backup option for when engrampa UI overflows screen and is unusale (xarchiver UI fails in different ways)
    ];

    pcGuiApps = declPackageSet [
      # package sets
      "pcGameApps"
      "pcTuiApps"
      ####
      "audacity"
      "brave"  # for the integrated wallet -- as a backup
      # "cantata"  # music player (mpd frontend)
      # "chromium"  # chromium takes hours to build. brave is chromium-based, distributed in binary form, so prefer it.
      "cups"
      "discord"  # x86-only
      # "electrum"
      "element-desktop"
      "firefox"
      "font-manager"
      # "gajim"  # XMPP client. cross build tries to import host gobject-introspection types (2023/09/01)
      "gimp"  # broken on phosh
      "google-chrome"  # for maximum compatibility
      # "gnome.dconf-editor"
      # "gnome.file-roller"
      # "gnome-disk-utility"
      "gparted"
      "nautilus"  # file browser
      # "gnome.totem"  # video player, supposedly supports UPnP
      "handbrake"
      "inkscape"
      # "jellyfin-media-player"
      # "kdenlive"  # N.B. depends on qtwebengine
      # "keymapp"
      # "kid3"  # audio tagging
      "krita"
      "libreoffice"  # TODO: replace with an office suite that uses saner packaging?
      "losslesscut-bin"  # x86-only  (TODO: replace with from-source build: <https://github.com/NixOS/nixpkgs/pull/385535>)
      # "makemkv"  # x86-only
      # "monero-gui"  # x86-only
      "mumble"
      # "nheko"  # Matrix chat client
      "nicotine-plus"  # soulseek client
      # "obsidian"
      # "openscad"  # 3d modeling
      # "rhythmbox"  # local music player
      # "slic3r"
      "soundconverter"
      # "spotify"  # x86-only
      "tor-browser"  # x86-only
      # "vlc"
      "wireshark"  # could maybe ship the cli as sysadmin pkg
      # "xterm"  # requires Xwayland
      # "zecwallet-lite"  # x86-only
      # "zulip"
    ];


    # INDIVIDUAL PACKAGE DEFINITIONS

    # alsa-utils amixer, aplay, speaker-test, ...
    alsa-utils.sandbox.whitelistAudio = true;  #< not strictly necessary?
    alsa-utils.sandbox.extraPaths = [ "/dev/snd" ];
    alsa-utils.sandbox.autodetectCliPaths = "existingFile";  # for `aplay ./file.wav`

    backblaze-b2 = {};

    bandwhich.sandbox.capabilities = [
      # it recommends these caps
      # - new_raw is absolutely required
      # - dac_read_search + sys_ptrace are required to associate traffic with process names
      # - net_admin is... seemingly not actually required for anything?
      "dac_read_search"
      # "net_admin"
      "net_raw"
      "sys_ptrace"
    ];
    bandwhich.sandbox.keepPids = true;  #< so it can determine process names
    bandwhich.sandbox.tryKeepUsers = true;
    bandwhich.sandbox.net = "all";

    bash-language-server.sandbox.whitelistPwd = true;

    bc.sandbox.autodetectCliPaths = "existingFile";

    bridge-utils.sandbox.net = "all";

    "cacert.unbundled".sandbox.enable = false;  #< data only

    cdecl = {};

    clang = {};

    clang-tools.sandbox.whitelistPwd = true;

    clightning-sane.sandbox.extraPaths = [
      "/var/lib/clightning/bitcoin/lightning-rpc"
    ];

    colordiff.sandbox.autodetectCliPaths = "existingFile";  # for `aplay ./file.wav`

    # cryptsetup: typical use is `cryptsetup open /dev/loopxyz mappedName`, and creates `/dev/mapper/mappedName`
    cryptsetup.sandbox.extraPaths = [
      "/dev/mapper"
      "/dev/random"
      "/dev/urandom"
      "/run"  #< it needs the whole directory, at least if using landlock
      # "/proc"
      "/sys/dev/block"
      "/sys/devices"
    ];
    cryptsetup.sandbox.capabilities = [ "sys_admin" ];
    cryptsetup.sandbox.autodetectCliPaths = "existing";
    cryptsetup.sandbox.tryKeepUsers = true;
    cryptsetup.sandbox.keepIpc = true;

    ddrescue.sandbox.autodetectCliPaths = "existingOrParent";
    ddrescue.sandbox.tryKeepUsers = true;

    delfin.buildCost = 1;
    delfin.sandbox.whitelistAudio = true;
    delfin.sandbox.whitelistDbus.user = true;  #< TODO: reduce  # else `mpris` plugin crashes the player
    delfin.sandbox.whitelistDri = true;
    delfin.sandbox.whitelistWayland = true;
    delfin.sandbox.net = "clearnet";
    # auth token, preferences
    delfin.persist.byStore.private = [ ".config/delfin" ];

    difftastic.sandbox.autodetectCliPaths = "existing";

    dig.sandbox.net = "all";

    dmidecode.sandbox.extraPaths = [ "/sys/firmware/dmi" ];

    # dtc -o may write a file, so needs directory access
    dtc.sandbox.autodetectCliPaths = "existingFileOrParent";

    duplicity = {};

    e2fsprogs.sandbox.autodetectCliPaths = "existing";

    efibootmgr.sandbox.extraPaths = [
      "/sys/firmware/efi"
    ];

    electrum.buildCost = 1;
    electrum.sandbox.net = "all";  # TODO: probably want to make this run behind a VPN, always
    electrum.sandbox.whitelistWayland = true;
    electrum.persist.byStore.ephemeral = [ ".electrum" ];  #< TODO: use XDG dirs!

    endless-sky.buildCost = 1;
    endless-sky.persist.byStore.plaintext = [ ".local/share/endless-sky" ];
    endless-sky.sandbox.mesaCacheDir = ".cache/endless-sky/mesa";
    endless-sky.sandbox.whitelistAudio = true;
    endless-sky.sandbox.whitelistDri = true;
    endless-sky.sandbox.whitelistWayland = true;
    endless-sky.packageUnwrapped = pkgs.endless-sky.overrideAttrs (base: {
      nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
        pkgs.makeWrapper
      ];
      postInstall = (base.postInstall or "") + ''
        wrapProgram $out/bin/endless-sky --set SDL_VIDEODRIVER wayland
      '';
    });

    # `emote` will show a first-run dialog based on what's in this directory.
    # mostly, it just keeps a LRU of previously-used emotes to optimize display order.
    # TODO: package [smile](https://github.com/mijorus/smile) for probably a better mobile experience.
    emote.persist.byStore.plaintext = [ ".local/share/Emote" ];

    erdtree.sandbox.tryKeepUsers = true;  #< to keep user/group info when running as root
    erdtree.sandbox.autodetectCliPaths = "existingDir";
    erdtree.sandbox.whitelistPwd = true;

    ethtool.sandbox.capabilities = [ "net_admin" ];
    ethtool.sandbox.net = "all";
    ethtool.sandbox.tryKeepUsers = true;

    evtest.sandbox.autodetectCliPaths = "existingFile";  # `evtest /dev/foo` to monitor events for a specific device
    evtest.sandbox.extraPaths = [
      "/dev/input"
    ];

    # eza `ls` replacement
    # bwrap causes `/proc` files to be listed differently (e.g. `eza /proc/sys/net/ipv6/conf/`)
    # bwrap loses group info (so files owned by other users appear as owner "nobody")
    eza.sandbox.tryKeepUsers = true;  #< to keep user/group info when running as root
    eza.sandbox.autodetectCliPaths = "existing";
    eza.sandbox.whitelistPwd = true;
    # eza.sandbox.extraHomePaths = [
    #   # so that e.g. `eza -l ~` can show which symlink exist
    #   # hol' up: this is almost like just un-sandboxing it
    #   ".persist/ephemeral"
    #   ".persist/plaintext"
    # ];

    fatresize.sandbox.autodetectCliPaths = "parent";  # /dev/sda1 -> needs /dev/sda
    fatresize.sandbox.tryKeepUsers = true;

    fd.sandbox.autodetectCliPaths = "existing";
    fd.sandbox.whitelistPwd = true;
    fd.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    ffmpeg.buildCost = 1;
    ffmpeg.sandbox.autodetectCliPaths = "existingFileOrParent";  # it outputs uncreated files -> parent dir needs mounting

    file.sandbox.autodetectCliPaths = "existing";  #< file OR directory, yes

    findutils.sandbox.enable = false;  #< `find -exec FOO`, needs to exec arbitrary commands
    # findutils.sandbox.autodetectCliPaths = "existing";
    # findutils.sandbox.whitelistPwd = true;
    # findutils.sandbox.extraHomePaths = [
    #   # let it follow symlinks to non-sensitive data
    #   ".persist/ephemeral"
    #   ".persist/plaintext"
    # ];

    font-manager.buildCost = 1;
    font-manager.sandbox.mesaCacheDir = ".cache/font-manager/mesa";
    font-manager.sandbox.whitelistWayland = true;
    font-manager.packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.font-manager.override {
      # build without the "Google Fonts" integration feature, to save closure / avoid webkitgtk_4_0
      withWebkit = false;
    });

    forkstat.sandbox.keepPidsAndProc = true;
    forkstat.sandbox.tryKeepUsers = true;
    forkstat.sandbox.net = "all";  #< it errors without this, wish i knew why

    fuzzel.sandbox.whitelistWayland = true;
    fuzzel.persist.byStore.private = [
      # this is a file of recent selections
      { path=".cache/fuzzel"; type="file"; }
    ];

    gawk.sandbox.wrapperType = "inplace";  # /share/gawk libraries refer to /libexec
    gawk.sandbox.autodetectCliPaths = "existingFile";

    geoclue2-with-demo-agent = {};

    # MS GitHub stores auth token in .config
    # TODO: we can populate gh's stuff statically; it even lets us use the same oauth across machines
    gh.persist.byStore.private = [ ".config/gh" ];

    gimp.buildCost = 1;
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
    gimp.suggestedPrograms = [
      "xwayland"  #< XXX(2024-11-10): version 3.0 should support wayland, but not 2.x
    ];

    git-lfs.sandbox.method = null;  #< TODO: sandbox

    gitea = {};

    gnome-calculator.buildCost = 1;
    gnome-calculator.sandbox.mesaCacheDir = ".cache/gnome-calculator/mesa";  # TODO: is this the correct app-id?
    gnome-calculator.sandbox.whitelistWayland = true;

    gnome-calendar.buildCost = 2;  # depends on webkitgtk_6_0 via evolution-data-server
    gnome-calendar.sandbox.mesaCacheDir = ".cache/gnome-calendar/mesa";  # TODO: is this the correct app-id?
    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    gnome-calendar.sandbox.whitelistWayland = true;
    gnome-calendar.sandbox.whitelistDbus.user = true;  #< TODO: reduce
    gnome-calendar.suggestedPrograms = [
      "evolution-data-server"  #< to access/persist calendar events
    ];

    # gnome-disks
    # XXX(2024-09-02): fails to show any disks even when run as `BUNPEN_DISABLE=1 sudo -E gnome-disks`.
    gnome-disk-utility.buildCost = 1;
    gnome-disk-utility.sandbox.whitelistDbus.system = true;
    gnome-disk-utility.sandbox.whitelistWayland = true;
    gnome-disk-utility.sandbox.extraHomePaths = [
      "tmp"
      "use/iso"
      # TODO: probably need /dev and such
    ];

    gnome-screenshot.sandbox.method = null;

    google-chrome.sandbox.enable = false;  # google-chrome is my "pleeeaaase work" fallback, so let it do anything.

    # gparted: run with `sudo -E gparted` (-E to keep the wayland socket)
    gparted.sandbox.tryKeepUsers = true;
    gparted.sandbox.capabilities = [ "dac_override" "sys_admin" ];
    gparted.sandbox.extraPaths = [
      "/dev"  #< necessary to see any devices
      "/proc"  #< silences segfaults when it invokes `pidof` on its children
      "/sys"  #< silences "partition has been written but unable to inform the kernel ..."
    ];
    gparted.sandbox.extraRuntimePaths = [
      "dconf"  #< silences "unable to create file '/run/user/colin/dconf/user': Permission denied.  dconf will not work properly."
    ];
    gparted.sandbox.whitelistWayland = true;

    hping.sandbox.net = "all";
    hping.sandbox.capabilities = [ "net_raw" ];
    hping.sandbox.autodetectCliPaths = "existingFile";  # for sending packet data from file
    hping.sandbox.tryKeepUsers = true;

    hyperfine.sandbox.enable = false;  #< it's a launcher

    # seahorse: dump gnome-keyring secrets.
    seahorse.buildCost = 1;
    # N.B. it can lso manage ~/.ssh keys, but i explicitly don't add those to the sandbox for now.
    seahorse.sandbox.whitelistDbus.user = true;  #< TODO: reduce
    seahorse.sandbox.whitelistWayland = true;

    gnome-2048.buildCost = 1;
    gnome-2048.sandbox.whitelistWayland = true;
    gnome-2048.sandbox.mesaCacheDir = ".cache/gnome-2048/mesa";
    gnome-2048.persist.byStore.plaintext = [ ".local/share/gnome-2048/scores" ];

    gnugrep.sandbox.autodetectCliPaths = "existing";
    gnugrep.sandbox.whitelistPwd = true;
    gnugrep.sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    gnused.sandbox.autodetectCliPaths = "existingFile";
    gnused.sandbox.whitelistPwd = true;  #< `-i` flag creates a temporary file in pwd (?) and then moves it.

    gpsd = {};

    gptfdisk.sandbox.extraPaths = [
      "/dev"
    ];
    gptfdisk.sandbox.autodetectCliPaths = "existing";  #< sometimes you'll use gdisk on a device file.

    # N.B.: if the user doesn't specify an output path, `grim` will output to ~/Pictures (which isn't included in this sandbox)
    grim.sandbox.autodetectCliPaths = "existingOrParent";
    grim.sandbox.whitelistWayland = true;

    hase.buildCost = 1;
    hase.sandbox.net = "clearnet";
    hase.sandbox.whitelistAudio = true;
    hase.sandbox.whitelistDri = true;
    hase.sandbox.whitelistWayland = true;

    # hdparm: has to be run as sudo. e.g. `sudo hdparm -i /dev/sda`
    hdparm.sandbox.autodetectCliPaths = "existingFile";
    hdparm.sandbox.tryKeepUsers = true;

    # hitori rules:
    # - click to shade a tile
    # 1. no number may appear unshaded more than once in the same row/column
    # 2. no two shaded tiles can be direct N/S/E/W neighbors
    # - win once (1) and (2) are satisfied
    hitori.buildCost = 1;
    hitori.sandbox.whitelistWayland = true;

    host.sandbox.net = "all";  #< technically, only needs to contact localhost's DNS server

    iftop.sandbox.net = "all";
    iftop.sandbox.capabilities = [ "net_raw" ];
    iftop.sandbox.tryKeepUsers = true;

    # inetutils: ping, ifconfig, hostname, traceroute, whois, ....
    # N.B.: inetutils' `ping` is shadowed by iputils' ping (by nixos, intentionally).
    inetutils.sandbox.net = "all";
    inetutils.sandbox.capabilities = [ "net_raw" ];  # for `sudo traceroute google.com`
    inetutils.sandbox.tryKeepUsers = true;

    iotop.sandbox.capabilities = [ "net_admin" ];
    iotop.sandbox.keepPidsAndProc = true;
    iotop.sandbox.tryKeepUsers = true;

    # provides `ip`, `routel`, `bridge`, others.
    # landlock works fine for most of these, but `ip netns exec` wants to attach to an existing namespace (which requires sudo)
    # and that means we can't use ANY sandboxer for it.
    iproute2.sandbox.method = null;  #< TODO: sandbox
    # iproute2.sandbox.net = "all";
    # iproute2.sandbox.capabilities = [ "net_admin" ];
    # iproute2.sandbox.extraPaths = [
    #   "/run/netns"  # for `ip netns ...` to work, but maybe not needed anymore?
    #   "/sys/class/net"  # for `ip netns ...` to work
    #   "/var/run/netns"
    # ];

    iptables.sandbox.method = null;  # TODO: sandbox
    # iptables.sandbox.net = "all";
    # iptables.sandbox.capabilities = [ "net_admin" ];

    # iputils provides `ping` (and arping, clockdiff, tracepath)
    iputils.sandbox.net = "all";
    iputils.sandbox.capabilities = [ "net_raw" ];
    iputils.sandbox.tryKeepUsers = true;  # for `sudo arping 10.78.79.1`

    iw.sandbox.net = "all";
    iw.sandbox.capabilities = [ "net_admin" ];
    iw.sandbox.tryKeepUsers = true;

    jq.sandbox.autodetectCliPaths = "existingFile";

    killall.sandbox.keepPidsAndProc = true;

    landlock-sandboxer.sandbox.enable = false;  #< sandbox helper

    libcap_ng.sandbox.enable = false;  # TODO: `pscap` can sandbox with bwrap, `captest` and `netcap` with landlock

    libgpiod.sandbox.extraPaths = [
      "/dev"  # really, /dev/gpiochip*
      "/sys/bus/gpio"
      "/sys/dev/char"
      "/sys/devices"
    ];

    libnotify.sandbox.whitelistDbus.user = true;  #< TODO: reduce  # notify-send

    libqmi.sandbox.method = null;  #< TODO: sandbox

    lightning-cli.packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.clightning "lightning-cli";
    lightning-cli.sandbox.extraHomePaths = [
      ".lightning/bitcoin/lightning-rpc"
    ];
    # `lightning-cli` finds its RPC file via `~/.lightning/bitcoin/lightning-rpc`, to message the daemon
    lightning-cli.fs.".lightning".symlink.target = "/var/lib/clightning";

    losslesscut-bin.buildCost = 1;
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
    # losslesscut-bin.sandbox.whitelistX = true;
    losslesscut-bin.sandbox.mesaCacheDir = ".cache/losslesscut/mesa";  # TODO: is this the correct app-id?
    losslesscut-bin.packageUnwrapped = pkgs.losslesscut-bin.overrideAttrs (base: {
      extraMakeWrapperArgs = (base.extraMakeWrapperArgs or []) ++ [
        "--append-flags '--ozone-platform-hint=auto --ozone-platform=wayland --enable-features=WaylandWindowDecorations'"
      ];
    });

    # use: `lsof`; `sudo lsof -i 4`
    lsof.sandbox.keepPidsAndProc = true;
    lsof.sandbox.capabilities = [ "dac_override" "sys_ptrace" ];
    # `lsof -i 4` demands we keep net, and also for some reason `/`.
    #   not just everything reachable from `/` (i.e. `/bin`, `/boot`, ...), but `/` itself.
    #   this is the case both for bunpen and for landlock.
    lsof.sandbox.tryKeepUsers = true;
    lsof.sandbox.net = "all";
    lsof.sandbox.extraPaths = [ "/" ];

    ltex-ls.sandbox.whitelistPwd = true;

    lua = {};

    lua-language-server.sandbox.whitelistPwd = true;

    man-pages.sandbox.enable = false;  #< data only
    man-pages-posix.sandbox.enable = false;  #< data only

    marksman.sandbox.whitelistPwd = true;

    mesa-demos.sandbox.whitelistDri = true;
    mesa-demos.sandbox.whitelistWayland = true;
    mesa-demos.sandbox.whitelistX = true;

    meson = {};

    # millipixels.packageUnwrapped = pkgs.millipixels.override {
    #   v4l-utils = config.sane.programs.v4l-utils.packageUnwrapped;  # necessary for cross compilation
    # };
    millipixels.sandbox.method = null;  #< TODO: sandbox

    # actual monero blockchain (not wallet/etc; safe to delete, just slow to regenerate)
    monero-gui.buildCost = 1;
    # XXX: is it really safe to persist this? it doesn't have info that could de-anonymize if captured?
    monero-gui.persist.byStore.plaintext = [ ".bitmonero" ];
    monero-gui.sandbox.net = "all";
    monero-gui.sandbox.extraHomePaths = [
      "records/finance/cryptocurrencies/monero"
    ];

    mozlz4a.sandbox.autodetectCliPaths = "existingOrParent";

    # mslicer.sandbox.method = null;  #< TODO: sandbox

    nano.sandbox.autodetectCliPaths = "existingFileOrParent";

    netcat.sandbox.net = "all";

    nethogs.sandbox.capabilities = [ "net_admin" "net_raw" ];
    nethogs.sandbox.tryKeepUsers = true;
    nethogs.sandbox.net = "all";

    # provides `arp`, `hostname`, `route`, `ifconfig`
    nettools.sandbox.net = "all";
    nettools.sandbox.capabilities = [ "net_admin" "net_raw" ];

    networkmanagerapplet.sandbox.whitelistWayland = true;
    networkmanagerapplet.sandbox.whitelistDbus.system = true;

    nfs-utils.sandbox.method = null;  #< TODO: sandbox

    nil.sandbox.whitelistPwd = true;
    nil.sandbox.keepPids = true;

    nixd.sandbox.whitelistPwd = true;

    nix-check-deps.sandbox.whitelistPwd = true;
    nix-check-deps.sandbox.net = "all";
    nix-check-deps.sandbox.extraPaths = [
      "/nix/var"
    ];

    nix-tree.sandbox.extraPaths = [
      "/nix/var"
    ];

    nixfmt.sandbox.autodetectCliPaths = "existingDirOrParent";  #< it formats via rename

    nixpkgs-hammering.sandbox.whitelistPwd = true;
    nixpkgs-hammering.sandbox.extraPaths = [
      "/nix/var"  # to prevent complaints about it not finding build logs
    ];

    nmap.sandbox.net = "all";  # clearnet and lan

    nmon.sandbox.keepPidsAndProc = true;
    nmon.sandbox.net = "all";

    nodejs = {};

    # `nvme list`
    nvme-cli.sandbox.extraPaths = [
      "/sys/devices"
      "/sys/class/nvme"
      "/sys/class/nvme-subsystem"
      "/sys/class/nvme-generic"
      "/dev"
    ];
    # nvme-cli.sandbox.capabilities = [ "sys_rawio" ];

    # contains only `oathtool`, which i only use for evaluating TOTP codes from CLI/stdin
    oath-toolkit = {};

    # settings (electron app)
    obsidian.persist.byStore.plaintext = [ ".config/obsidian" ];

    oils-for-unix.sandbox.enable = false;  #< it's a shell; doesn't make sense to sandbox

    openscad-lsp.sandbox.whitelistPwd = true;

    openssl.sandbox.net = "clearnet";

    passt.sandbox.enable = false;  #< sandbox helper (netns specifically)

    parted.sandbox.extraPaths = [
      "/dev"
    ];
    parted.sandbox.autodetectCliPaths = "existing";  #< sometimes you'll use parted on a device file.

    patchelf.sandbox.method = null;  #< TODO: sandbox

    pavucontrol.sandbox.whitelistAudio = true;
    pavucontrol.sandbox.whitelistDri = true;  #< to be a little more responsive
    pavucontrol.sandbox.whitelistWayland = true;
    pavucontrol.sandbox.mesaCacheDir = ".cache/pavucontrol/mesa";

    pciutils.sandbox.extraPaths = [
      "/sys/bus/pci"
      "/sys/devices"
    ];

    # e.g. `picocom -b 115200 /dev/ttyUSB0`
    picocom.sandbox.autodetectCliPaths = "existingFile";

    powersupply.sandbox.whitelistWayland = true;
    powersupply.sandbox.extraPaths = [
      "/sys/class/power_supply"
      "/sys/devices"
    ];

    powertop.sandbox.capabilities = [ "ipc_lock" "sys_admin" ];
    powertop.sandbox.tryKeepUsers = true;
    powertop.sandbox.extraPaths = [
      "/proc"
      "/sys/class"
      "/sys/devices"
      "/sys/kernel"
    ];

    procs.sandbox.keepPidsAndProc = true;
    procs.sandbox.tryKeepUsers = true;  # if running as root, keep the user namespace so it can render usernames
    procs.sandbox.capabilities = [ "setfcap" ];  #< this seems wrong, but when running as root without it, it fails

    # procps: free, pgrep, pidof, pkill, ps, pwait, top, uptime, couple others
    procps.sandbox.keepPidsAndProc = true;

    pstree.sandbox.keepPidsAndProc = true;

    pulseaudio.sandbox.method = null;  #< TODO: sandbox

    pulsemixer.sandbox.whitelistAudio = true;

    pwvucontrol.buildCost = 1;
    pwvucontrol.sandbox.whitelistAudio = true;
    pwvucontrol.sandbox.whitelistDri = true;  # else perf on moby is unusable
    pwvucontrol.sandbox.whitelistWayland = true;
    pwvucontrol.sandbox.mesaCacheDir = ".cache/pwvucontrol/mesa";  # TODO: is this the correct app-id?

    pyright.sandbox.whitelistPwd = true;

    python3-repl.packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      libgpiod
      numpy
      psutil
      pykakasi
      requests
      scipy
      unidecode
    ]);
    python3-repl.sandbox.net = "clearnet";
    python3-repl.sandbox.autodetectCliPaths = "existing";  #< for invoking scripts like `python3 ./my-script.py`
    python3-repl.sandbox.extraHomePaths = [
      "/"  #< this is 'safe' because with don't expose .persist/private, so no .ssh/id_ed25519
      ".persist/plaintext"
    ];

    qemu.sandbox.enable = false;  #< it's a launcher
    qemu.buildCost = 2;

    rsync.sandbox.net = "clearnet";
    rsync.sandbox.autodetectCliPaths = "existingOrParent";
    rsync.sandbox.tryKeepUsers = true;  # if running as root, keep the user namespace so that `-a` can set the correct owners, etc
    rsync.sandbox.whitelistSsh = true;

    rust-analyzer.buildCost = 2;
    rust-analyzer.sandbox.whitelistPwd = true;
    rust-analyzer.suggestedPrograms = [
      "cargo"
    ];

    rustc = {};

    rustup = {};

    sane-cast.sandbox.net = "clearnet";
    sane-cast.sandbox.autodetectCliPaths = "existingFile";
    sane-cast.sandbox.whitelistAudio = true;  #< for sblast audio casting
    sane-cast.suggestedPrograms = [ "go2tv" "sblast" ];

    sane-color-picker.sandbox.whitelistDbus.user = true;  #< TODO: reduce  #< required for eyedropper to work
    sane-color-picker.sandbox.whitelistWayland = true;
    sane-color-picker.sandbox.keepPidsAndProc = true;  #< required by wl-clipboard
    sane-color-picker.suggestedPrograms = [
      "gnugrep"
      "wl-clipboard"
      # "zenity"
    ];
    sane-color-picker.sandbox.mesaCacheDir = ".cache/sane-color-picker/mesa";  # TODO: is this the correct app-id?

    sane-die-with-parent.sandbox.enable = false;  #< it's a launcher; can't sandbox

    sane-weather.sandbox.net = "clearnet";

    sc-im.sandbox.autodetectCliPaths = "existingFile";

    screen.sandbox.enable = false;  #< tty; needs to run anything

    # sequoia-sq.packageUnwrapped = pkgs.sequoia-sq.overrideAttrs (_: {
    #   # XXX(2024-07-30): sq_autocrypt_import test failure: "Warning: 9B7DD433F254904A is expired."
    #   doCheck = false;
    # });
    sequoia-sq.buildCost = 1;
    sequoia-sq.sandbox.whitelistPwd = true;
    sequoia-sq.sandbox.autodetectCliPaths = "existingFileOrParent";  # supports `-o <file-to-create>`

    shattered-pixel-dungeon.buildCost = 1;
    shattered-pixel-dungeon.persist.byStore.plaintext = [ ".local/share/.shatteredpixel/shattered-pixel-dungeon" ];
    shattered-pixel-dungeon.sandbox.whitelistAudio = true;
    shattered-pixel-dungeon.sandbox.whitelistDri = true;
    shattered-pixel-dungeon.sandbox.whitelistWayland = true;
    shattered-pixel-dungeon.sandbox.mesaCacheDir = ".cache/.shatteredpixel/mesa";

    # printer/filament settings
    slic3r.buildCost = 1;
    # slic3r.persist.byStore.plaintext = [
    #   ".Slic3r"  #< printer/filament settings
    # ];
    slic3r.sandbox.autodetectCliPaths = "existingFileOrParent";  # slic3r <my-file>.stl -o <out>.gcode

    slurp.sandbox.whitelistWayland = true;

    snapper.sandbox.tryKeepUsers = true;
    snapper.sandbox.whitelistDbus.system = true;  #< all `snapper` does is speak to the daemon, via dbus

    # snapshot camera, based on libcamera
    # TODO: enable dma heaps for more efficient buffer sharing: <https://gitlab.com/postmarketOS/pmaports/-/issues/2789>
    snapshot.sandbox.method = null;  #< TODO: sandbox

    sox.sandbox.autodetectCliPaths = "existingFileOrParent";
    sox.sandbox.whitelistAudio = true;

    space-cadet-pinball.buildCost = 1;
    space-cadet-pinball.persist.byStore.plaintext = [ ".local/share/SpaceCadetPinball" ];
    space-cadet-pinball.sandbox.mesaCacheDir = ".cache/SpaceCadetPinball/mesa";  # TODO: is this the correct app-id?
    space-cadet-pinball.sandbox.whitelistAudio = true;
    space-cadet-pinball.sandbox.whitelistDri = true;
    space-cadet-pinball.sandbox.whitelistWayland = true;

    speedtest-cli.sandbox.net = "all";

    sqlite.sandbox.method = null;  #< TODO: sandbox

    ssh-to-age.sandbox.autodetectCliPaths = "existingFile";

    # N.B. if you call sshfs-fuse from the CLI -- without `mount.fuse` -- disable sandboxing
    sshfs-fuse.sandbox.net = "all";
    sshfs-fuse.sandbox.autodetectCliPaths = "parent";
    # sshfs-fuse.sandbox.extraPaths = [
    #   "/dev/fd"  # fuse.mount3 -o drop_privileges passes us data over /dev/fd/3
    #   "/mnt"  # XXX: not sure why i need all this, instead of just /mnt/desko, or /mnt/desko/home, etc
    # ];
    sshfs-fuse.sandbox.extraHomePaths = [
      ".ssh/id_ed25519"  #< TODO: add -o foo,bar=path/to/thing style arguments to autodetection
    ];
    sshfs-fuse.sandbox.keepPids = true;  #< XXX: bwrap didn't need this, but bunpen does. why?

    sshpass.sandbox.autodetectCliPaths = "existingFile";  #< for `sshpass -f <path/to/password/file>`

    strace.sandbox.enable = false;  #< needs to `exec` its args, and therefore support *anything*

    subversion.sandbox.net = "clearnet";
    subversion.sandbox.whitelistPwd = true;
    sudo.sandbox.enable = false;

    superTux.buildCost = 1;
    superTux.sandbox.whitelistAudio = true;
    superTux.sandbox.whitelistDri = true;
    superTux.sandbox.whitelistWayland = true;
    # superTux.sandbox.whitelistX = true;
    superTux.sandbox.mesaCacheDir = ".cache/supertux2/mesa";  # TODO: is this the correct app-id?
    superTux.persist.byStore.plaintext = [ ".local/share/supertux2" ];
    superTux.packageUnwrapped = pkgs.superTux.overrideAttrs (base: {
      nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
        pkgs.makeWrapper
      ];
      postInstall = (base.postInstall or "") + ''
        wrapProgram $out/bin/supertux2 --set SDL_VIDEODRIVER wayland
      '';
    });

    swaybg.sandbox.method = null;  #< TODO: sandbox

    swappy.sandbox.autodetectCliPaths = "existingFileOrParent";
    swappy.sandbox.whitelistWayland = true;

    systemctl.packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.systemdMinimal "systemctl";
    systemctl.sandbox.whitelistSystemctl = true;
    # for `sudo systemctl edit --runtime FOO`
    systemctl.sandbox.capabilities = [ "cap_dac_override" "cap_sys_admin" ];
    systemctl.sandbox.keepPidsAndProc = true;

    tdesktop.persist.byStore.private = [ ".local/share/TelegramDesktop" ];

    tokodon.buildCost = 1;
    tokodon.persist.byStore.private = [ ".cache/KDE/tokodon" ];

    tree.sandbox.autodetectCliPaths = "existing";
    tree.sandbox.whitelistPwd = true;
    tree.sandbox.tryKeepUsers = true;
    tree.sandbox.capabilities = [ "dac_read_search" ];

    typescript-language-server.buildCost = 2;
    typescript-language-server.sandbox.whitelistPwd = true;
    typescript-language-server.persist.byStore.ephemeral = [
      ".cache/typescript"
      ".npm"  # .npm/{_cacache,_logs}
    ];

    tumiki-fighters.buildCost = 1;
    tumiki-fighters.sandbox.whitelistAudio = true;
    tumiki-fighters.sandbox.whitelistDri = true;  #< not strictly necessary, but triples CPU perf
    tumiki-fighters.sandbox.whitelistWayland = true;
    tumiki-fighters.sandbox.whitelistX = true;
    tumiki-fighters.sandbox.mesaCacheDir = ".cache/tumiki-fighters/mesa";  # TODO: is this the correct app-id?
    tumiki-fighters.suggestedPrograms = [
      "xwayland"  #< XXX(2024-11-10): does not start without X(wayland), not even with SDL_VIDEDRIVER=wayland
    ];

    util-linux.sandbox.method = null;  #< TODO: possible to sandbox if i specify a different profile for each of its ~50 binaries

    "unixtools.ps".sandbox.keepPidsAndProc = true;
    "unixtools.sysctl" = {};  #< XXX: probably not sandboxed correctly for sysctl writes; only for reads

    unzip.sandbox.autodetectCliPaths = "existingOrParent";
    unzip.sandbox.whitelistPwd = true;

    # usbutils.sandbox.method = null;  # fixes `usbhid-dump`. OTOH `lsusb`, `usb-devices` work under bunpen
    usbutils.sandbox.extraPaths = [
      "/sys/devices"
      "/sys/bus/usb"
    ];

    uvtools.sandbox.method = null;  #< TODO: sandbox

    vala-language-server.sandbox.whitelistPwd = true;
    vala-language-server.suggestedPrograms = [
      # might someday support cmake, too: <https://github.com/vala-lang/vala-language-server/issues/73>
      "meson"
    ];

    valgrind.buildCost = 1;
    valgrind.sandbox.enable = false;  #< it's a launcher: can't sandbox

    # `vulkaninfo`, `vkcube`
    vulkan-tools.sandbox.whitelistDri = true;
    vulkan-tools.sandbox.whitelistWayland = true;
    vulkan-tools.sandbox.whitelistX = true;
    vulkan-tools.sandbox.extraPaths = [
      "/sys/dev/char"
      "/sys/devices"
    ];

    vvvvvv.buildCost = 1;
    vvvvvv.sandbox.whitelistAudio = true;
    vvvvvv.sandbox.whitelistDri = true;  #< playable without, but burns noticably more CPU
    vvvvvv.sandbox.whitelistWayland = true;
    vvvvvv.sandbox.mesaCacheDir = ".cache/VVVVVV/mesa";
    vvvvvv.persist.byStore.plaintext = [ ".local/share/VVVVVV" ];

    w3m.sandbox.net = "all";
    w3m.sandbox.extraHomePaths = [
      # little-used feature, but you can save web pages :)
      "tmp"
    ];

    watch.sandbox.enable = false;  #< it executes the command it's given

    wdisplays.sandbox.mesaCacheDir = ".cache/wdisplays/mesa";  # TODO: is this the correct app-id?
    wdisplays.sandbox.whitelistWayland = true;

    wget.sandbox.net = "all";
    wget.sandbox.whitelistPwd = true;  # saves to pwd by default

    whalebird.buildCost = 1;
    whalebird.persist.byStore.private = [ ".config/Whalebird" ];

    # `wg`, `wg-quick`
    wireguard-tools.sandbox.net = "all";
    wireguard-tools.sandbox.capabilities = [ "net_admin" ];
    wireguard-tools.sandbox.tryKeepUsers = true;

    # provides `iwconfig`, `iwlist`, `iwpriv`, ...
    wirelesstools.sandbox.net = "all";
    wirelesstools.sandbox.capabilities = [ "net_admin" ];
    wirelesstools.sandbox.tryKeepUsers = true;

    wiremix.sandbox.whitelistAudio = true;

    wl-clipboard.sandbox.whitelistWayland = true;
    wl-clipboard.sandbox.keepPids = true;  #< this is needed, but not sure why?

    wtype = {};
    wtype.sandbox.whitelistWayland = true;

    xwayland.sandbox.wrapperType = "inplace";  #< consumers use it as a library (e.g. wlroots)
    xwayland.sandbox.whitelistWayland = true;  #< just assuming this is needed
    xwayland.sandbox.whitelistX = true;
    xwayland.sandbox.whitelistDri = true;  #< would assume this gives better gfx perf
    xwayland.sandbox.mesaCacheDir = ".cache/xwayland/mesa";  # TODO: is this the correct app-id?

    xterm.sandbox.enable = false;  # need to be able to do everything

    yarn.persist.byStore.plaintext = [ ".cache/yarn" ];
  };

  sane.persist.sys.byStore.plaintext = lib.mkIf config.sane.programs.guiApps.enabled [
    # "/var/lib/alsa"                # preserve output levels, default devices
    {
      # backlight brightness; MUST be `bind`, else systemd loses its shit with "Too many levels of symbolic links".
      path = "/var/lib/systemd/backlight";
      method = "bind";
    }
  ];

  hardware.graphics = lib.mkIf config.sane.programs.guiApps.enabled ({
    enable = true;
  } // (lib.optionalAttrs pkgs.stdenv.isx86_64 {
    # for 32 bit applications
    # upstream nixpkgs forbids setting enable32Bit unless specifically x86_64 (so aarch64 isn't allowed)
    enable32Bit = lib.mkDefault true;
  }));

  system.activationScripts.notifyActive = lib.mkIf config.sane.programs.guiApps.enabled {
    text = let
      notify-active = pkgs.writeShellScriptBin "notify-active-inner" ''
        export PATH="/etc/profiles/per-user/$USER/bin:$PATH:${pkgs.libnotify}/bin"

        systemConfig="$1"
        NIXOS_VERSION="$(cat $systemConfig/nixos-version)"

        if [ -e "$HOME/.profile" ]; then
          . "$HOME/.profile"
        fi

        dbus_file="$XDG_RUNTIME_DIR/dbus/bus"
        if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -e "$dbus_file" ]; then
          export DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_file"
        fi

        if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
          notify-send "nixos activated" "version: $NIXOS_VERSION"
        fi
      '';
    in lib.concatStringsSep "\n" (lib.mapAttrsToList
        (user: en: lib.optionalString en ''${lib.getExe pkgs.sudo} -u "${user}" "${lib.getExe notify-active}" "$systemConfig" > /dev/null'')
        config.sane.programs.guiApps.enableFor.user
    );
  };
}
