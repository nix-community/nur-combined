{ config, lib, pkgs, ... }:
let
  declPackageSet = pkgs: {
    package = null;
    suggestedPrograms = pkgs;
  };
in
{
  imports = [
    ./gnome.nix
    ./greetd.nix
    ./gtk.nix
    ./phosh.nix
    ./sway
    ./sxmo
    ./theme
  ];

  sane.programs.gameApps = declPackageSet [
    "animatch"
    "gnome-2048"
    "gnome.hitori"  # like sudoku
    "superTux"  # keyboard-only controls
    "superTuxKart"  # poor FPS on pinephone
  ];
  sane.programs.pcGameApps = declPackageSet [
    # "andyetitmoves" # TODO: fix build!
    # "armagetronad"  # tron/lightcycles; WAN and LAN multiplayer
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
    "tumiki-fighters" # keyboard-only
    "vvvvvv"  # keyboard-only controls
    "wine"
  ];

  sane.programs.guiApps = declPackageSet [
    # package sets
    "gameApps"
    "guiBaseApps"
  ];

  sane.programs.guiBaseApps = declPackageSet [
    "abaddon"  # discord client
    "alacritty"  # terminal emulator
    "delfin"  # Jellyfin client
    "dialect"  # language translation
    "dino"  # XMPP client
    # "emote"
    "evince"  # works on phosh
    "flare-signal"  # gtk4 signal client
    # "foliate"  # e-book reader
    "fractal"  # matrix client
    "g4music"  # local music player
    # "gnome.cheese"
    # "gnome-feeds"  # RSS reader (with claimed mobile support)
    # "gnome.file-roller"
    "gnome.geary"  # adaptive e-mail client; uses webkitgtk 4.1
    "gnome.gnome-calculator"
    "gnome.gnome-calendar"
    "gnome.gnome-clocks"
    "gnome.gnome-maps"
    # "gnome-podcasts"
    # "gnome.gnome-system-monitor"
    # "gnome.gnome-terminal"  # works on phosh
    "gnome.gnome-weather"
    "gnome.seahorse"  # keyring/secret manager
    "gnome-frog"  # OCR/QR decoder
    "gpodder"
    # "gthumb"
    "gtkcord4"  # Discord client. 2023/11/21: disabled because v0.0.12 leaks memory
    "lemoa"  # lemmy app
    "libnotify"  # for notify-send; debugging
    # "lollypop"
    "loupe"  # image viewer
    "mate.engrampa"  # archive manager
    "mepo"  # maps viewer
    "mpv"
    "networkmanagerapplet"  # for nm-connection-editor: it's better than not having any gui!
    "ntfy-sh"  # notification service
    # "newsflash"  # RSS viewer
    "pavucontrol"
    "pwvucontrol"  # pipewire version of pavu
    # "picard"  # music tagging
    # "libsForQt5.plasmatube"  # Youtube player
    "signal-desktop"
    "spot"  # Gnome Spotfy client
    # "sublime-music"
    # "tdesktop"  # broken on phosh
    # "tokodon"
    "tuba"  # mastodon/pleroma client (stores pw in keyring)
    "vulkan-tools"  # vulkaninfo
    # "whalebird"  # pleroma client (Electron). input is broken on phosh.
    "xdg-terminal-exec"
    "xterm"  # broken on phosh
  ];

  sane.programs.handheldGuiApps = declPackageSet [
    "calls"  # gnome calls (dialer/handler)
    # "celluloid"  # mpv frontend
    # "chatty"  # matrix/xmpp/irc client  (2023/12/29: disabled because broken cross build)
    "cozy"  # audiobook player
    "epiphany"  # gnome's web browser
    # "iotas"  # note taking app
    "komikku"
    "koreader"
    "megapixels"  # camera app
    "notejot"  # note taking, e.g. shopping list
    "planify"  # todo-tracker/planner
    "portfolio-filemanager"
    "tangram"  # web browser
    "wike"  # Wikipedia Reader
    "xarchiver"
  ];

  sane.programs.pcGuiApps = declPackageSet (
    [
      # package sets
      "pcGameApps"
      "pcTuiApps"
    ] ++ [
      "audacity"
      "blanket"  # ambient noise generator
      "brave"  # for the integrated wallet -- as a backup
      # "cantata"  # music player (mpd frontend)
      # "chromium"  # chromium takes hours to build. brave is chromium-based, distributed in binary form, so prefer it.
      "discord"  # x86-only
      "electrum"
      "element-desktop"
      "firefox"
      "font-manager"
      # "gajim"  # XMPP client. cross build tries to import host gobject-introspection types (2023/09/01)
      "gimp"  # broken on phosh
      # "gnome.dconf-editor"
      # "gnome.file-roller"
      "gnome.gnome-disk-utility"
      "gnome.nautilus"  # file browser
      # "gnome.totem"  # video player, supposedly supports UPnP
      "handbrake"
      "inkscape"
      # "jellyfin-media-player"
      "kdenlive"
      "kid3"  # audio tagging
      "krita"
      "libreoffice"  # TODO: replace with an office suite that uses saner packaging?
      "losslesscut-bin"  # x86-only
      "makemkv"  # x86-only
      "monero-gui"  # x86-only
      "mumble"
      # "nheko"  # Matrix chat client
      # "obsidian"
      "openscad"  # 3d modeling
      # "rhythmbox"  # local music player
      # "slic3r"
      "soundconverter"
      "spotify"  # x86-only
      "steam"
      "tor-browser-bundle-bin"  # x86-only
      "vlc"
      "wireshark"  # could maybe ship the cli as sysadmin pkg
      "zecwallet-lite"  # x86-only
    ]
  );

  sane.persist.sys.byStore.plaintext = lib.mkIf config.sane.programs.guiApps.enabled [
    "/var/lib/alsa"                # preserve output levels, default devices
    "/var/lib/colord"              # preserve color calibrations (?)
    "/var/lib/systemd/backlight"   # backlight brightness
  ];

  hardware.opengl = lib.mkIf config.sane.programs.guiApps.enabled ({
    enable = true;
    driSupport = lib.mkDefault true;
  } // (lib.optionalAttrs pkgs.stdenv.isx86_64 {
    # for 32 bit applications
    # upstream nixpkgs forbids setting driSupport32Bit unless specifically x86_64 (so aarch64 isn't allowed)
    driSupport32Bit = lib.mkDefault true;
  }));
}
