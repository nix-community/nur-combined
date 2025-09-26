{ pkgs, ... }:
with pkgs;
[
  turbo
  eva
  paperback
  chatmcp
  thunderbird
  amberol
  nix-weather
  mako
  # qq
  # chromium
  # apotris
  # celeste
  stellarium
  # celluloid
  # thiefmd
  # wpsoffice
  # fractal
  mari0
  # anyrun
  # factorio
  loupe
  geo
  fractal-next
  gedit
  # logseq
  # jetbrains.pycharm-professional
  # jetbrains.idea-ultimate
  # jetbrains.clion
  # jetbrains.rust-rover

  # bottles

  kooha # recorder

  typst
  # blender-hip
  ruffle

  # fractal

  # yuzu-mainline
  # photoprism

  # virt-manager
  # xdg-utils
  hyfetch

  # microsoft-edge
  dosbox-staging
  meld
  # yubioath-flutter

  gimp
  imv

  veracrypt
  openpgp-card-tools
  tutanota-desktop

  # davinci-resolve
  # cava

  # wpsoffice-cn

  # sbctl
  qbittorrent

  protonmail-bridge

  koreader
  cliphist
  pcsctools
  ccid

  yubikey-manager
  # canokey-manager

  xdeltaUnstable

  # feeluown
  # feeluown-bilibili
  # # feeluown-local
  # feeluown-netease
  # feeluown-qqmusic

  # chntpw
  # libnotify

  # Perf
  # stress
  # s-tui

  # reader
  calibre
  mdbook
  sioyek
  zathura
  foliate
  librum

  # file
  filezilla
  file
  lapce
  # cinnamon.nemo
  nautilus
  # gnome-boxes
  evince
  # zathura

  # social
  discord
  # materialgram
  tdesktop
  # thunderbird
  # fluffychat
  scrcpy

  alacritty
  rio
  appimage-run
  tofi
  # zoom-us
  # gnomecast
  tetrio-desktop

  # ffmpeg_7-full

  # foot

  brightnessctl

  fuzzel
  swaybg
  wl-clipboard
  wf-recorder
  grim
  slurp

  tor-browser-bundle-bin

  vial

  android-tools
  zellij
  # netease-cloud-music-gtk
  cmatrix
  # kotatogram-desktop
  nmap
  lm_sensors

  pamixer
  ncpamixer
  # texlive.combined.scheme-full
  vlc
  # bluedevil
  prismlauncher
]
# ++ (with pkgs; [ fluent-icon-theme ])
++ [
  (writeTextFile {
    name = "index.theme";
    destination = "/share/icons/default/index.theme";
    # Set name in icons theme, for compatibility with AwesomeWM etc. See:
    # https://github.com/nix-community/home-manager/issues/2081
    # https://wiki.archlinux.org/title/Cursor_themes#XDG_specification
    text = ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=Bibata-Modern-Ice
    '';
  })
]
