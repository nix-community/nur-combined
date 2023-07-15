{ config, lib, pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./gtk.nix
    ./phosh.nix
    ./sway
    ./sxmo
  ];

  sane.programs.guiApps = {
    package = null;
    suggestedPrograms = [
      "firefox"
      "tuiApps"
    ] ++ lib.optional (pkgs.system == "x86_64-linux") "x86GuiApps"
    ++ [
      # "celluloid"  # mpv frontend
      "cozy"  # audiobook player
      # "emote"
      "epiphany"  # gnome's web browser
      "evince"  # works on phosh
      # "foliate"  # e-book reader
      # "gnome.cheese"
      # "gnome-feeds"  # RSS reader (with claimed mobile support)
      "gnome.file-roller"
      # "gnome.gnome-maps"  # works on phosh
      "gnome.nautilus"
      # "gnome-podcasts"
      # "gnome.gnome-system-monitor"
      # "gnome.gnome-terminal"  # works on phosh
      # "gnome.gnome-weather"
      "gpodder"
      "gthumb"
      "komikku"
      "koreader"
      "lemoa"  # lemmy app
      # "lollypop"
      "mepo"  # maps viewer
      # "mpv"
      # "networkmanagerapplet"
      # "newsflash"
      "nheko"
      "pavucontrol"
      # "picard"  # music tagging
      # "libsForQt5.plasmatube"  # Youtube player
      "soundconverter"
      # "sublime-music"
      "tangram"  # web browser
      # "tdesktop"  # broken on phosh
      # "tokodon"
      "tuba"  # mastodon/pleroma client (stores pw in keyring)
      "vlc"
      # "whalebird"  # pleroma client (Electron). input is broken on phosh.
      "xterm"  # broken on phosh
    ];
  };

  sane.programs.desktopGuiApps = {
    package = null;
    suggestedPrograms = [
      "audacity"
      "blanket"  # ambient noise generator
      "brave"  # for the integrated wallet -- as a backup
      "chromium"
      "dino"
      "electrum"
      "element-desktop"
      # "font-manager"  #< depends on webkitgtk4_0 (expensive to build)
      "gajim"  # XMPP client
      "gimp"  # broken on phosh
      "gnome.dconf-editor"
      "gnome.gnome-disk-utility"
      # "gnome.totem"  # video player, supposedly supports UPnP
      "handbrake"
      "hase"
      "inkscape"
      "jellyfin-media-player"
      "kdenlive"
      "kid3"  # audio tagging
      "krita"
      "libreoffice-fresh"
      "mumble"
      "obsidian"
      "slic3r"
      "steam"
      "wireshark"  # could maybe ship the cli as sysadmin pkg
    ];
  };

  sane.programs.handheldGuiApps = {
    package = null;
    suggestedPrograms = [
      "megapixels"  # camera app
    ];
  };

  sane.programs.x86GuiApps = {
    package = null;
    suggestedPrograms = [
      "discord"
      # "gnome.zenity" # for kaiteki (it will use qarma, kdialog, or zenity)
      # "gpt2tc"  # XXX: unreliable mirror
      # "kaiteki"  # Pleroma client
      # "logseq"  # Personal Knowledge Management
      "losslesscut-bin"
      "makemkv"
      "monero-gui"
      "signal-desktop"
      "spotify"
      "tor-browser-bundle-bin"
      "zecwallet-lite"
    ];
  };

  sane.persist.sys.plaintext = lib.mkIf config.sane.programs.guiApps.enabled [
    "/var/lib/alsa"                # preserve output levels, default devices
    "/var/lib/colord"              # preserve color calibrations (?)
    "/var/lib/systemd/backlight"   # backlight brightness
  ];
}
