{ pkgs, ... }:
with pkgs;
[
  # qq
  firefox
  chromium
  # dissent
  celeste
  stellarium
  obsidian
  celluloid
  thiefmd
  # wpsoffice
  fractal
  mari0
  # anyrun
  # factorio
  loupe
  gedit
  # logseq
  # jetbrains.pycharm-professional
  # jetbrains.idea-ultimate
  # jetbrains.clion
  # jetbrains.rust-rover

  # bottles

  kooha # recorder

  typst
  blender-hip
  ruffle

  # fractal

  # yuzu-mainline
  photoprism

  virt-manager
  xdg-utils
  fluffychat
  hyfetch

  # microsoft-edge
  dosbox-staging
  meld
  # yubioath-flutter
  openapi-generator-cli

  gimp
  imv

  veracrypt
  openpgp-card-tools
  tutanota-desktop

  # davinci-resolve
  cava

  # wpsoffice-cn

  sbctl
  qbittorrent

  protonmail-bridge

  koreader
  cliphist
  # realvnc-vnc-viewer
  #    mathematica
  pcsctools
  ccid

  # nrfconnect
  # nrfutil
  # nrf-command-line-tools
  yubikey-manager

  xdeltaUnstable
  xterm

  # feeluown
  # feeluown-bilibili
  # # feeluown-local
  # feeluown-netease
  # feeluown-qqmusic

  chntpw
  gkraken
  libnotify

  # Perf
  stress
  s-tui
  mprime

  # reader
  calibre
  # obsidian
  mdbook
  sioyek
  zathura
  foliate

  # file
  filezilla
  file
  lapce
  kate
  # cinnamon.nemo
  gnome.nautilus
  gnome.dconf-editor
  gnome.gnome-boxes
  gnome.evince
  # zathura

  # social
  # discord
  tdesktop
  nheko
  element-desktop-wayland
  # thunderbird
  # fluffychat
  scrcpy

  alacritty
  rio
  appimage-run
  lutris
  tofi
  # zoom-us
  # gnomecast
  tetrio-desktop

  ffmpeg_5-full

  foot

  brightnessctl

  fuzzel
  swaybg
  wl-clipboard
  wf-recorder
  grim
  slurp

  mongodb-compass
  tor-browser-bundle-bin

  vial

  android-tools
  zellij
  # netease-cloud-music-gtk
  cmatrix
  termius
  # kotatogram-desktop
  nmap
  lm_sensors

  feh
  pamixer
  sl
  ncpamixer
  # texlive.combined.scheme-full
  vlc
  bluedevil
  julia-bin
  prismlauncher
]
++ (with pkgs; [
  rust-analyzer
  # nil
  nixd
  shfmt
  nixfmt-rfc-style
  # taplo
  rustfmt
  clang-tools
  # haskell-language-server
  cmake-language-server
  arduino-language-server
  typst-lsp
  vhdl-ls
  delve
  python311Packages.python-lsp-server
  tinymist
])
++ (with pkgs.nodePackages_latest; [
  vscode-json-languageserver-bin
  vscode-html-languageserver-bin
  vscode-css-languageserver-bin
  bash-language-server
  vls
  prettier
])
