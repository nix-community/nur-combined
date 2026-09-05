# Might be a bit overkill of an FHS env BUT idk what those games exactly need so I'd rather not take risk
{
  lib,
  buildFHSEnv,
  twintaillauncher-unwrapped,
  extraPkgs ? pkgs: [ ],
  extraLibraries ? pkgs: [ ],
}:

let
  qt5Deps =
    pkgs: with pkgs.qt5; [
      qtbase
      qtmultimedia
    ];
  qt6Deps = pkgs: with pkgs.qt6; [ qtbase ];
  gnomeDeps =
    pkgs: with pkgs; [
      zenity
      gtksourceview
      gnome-desktop
      libgnome-keyring
      webkitgtk_4_1
      adwaita-icon-theme
    ];
  xorgDeps =
    pkgs: with pkgs; [
      libx11
      libxrender
      libxrandr
      libxcb
      libxmu
      libpthread-stubs
      libxext
      libxdmcp
      libxxf86vm
      libxinerama
      libsm
      libxv
      libxaw
      libxi
      libxcursor
      libxcomposite
      libxfixes
      libxtst
      libxscrnsaver
      libice
      libxt
    ];
  gstreamerDeps =
    pkgs: with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-ugly
      gst-plugins-bad
      gst-libav
    ];
in
buildFHSEnv {
  pname = "twintaillauncher";
  inherit (twintaillauncher-unwrapped) version meta;

  runScript = lib.getExe twintaillauncher-unwrapped;
  multiArch = true;
 
  targetPkgs = pkgs: with pkgs; [
    twintaillauncher-unwrapped
    
    # Launcher dependencies
    # gsettings-desktop-schemas
    # libayatana-appindicator
    # libappindicator-gtk3
    # webkitgtk_4_1
    # gdk-pixbuf
    # cairo
    # pango
    # glib
    # gtk3
    # nss

    # Game runtime dependencies
    mangohud
    gamemode

    # WINE
    xrandr
    perl
    which
    p7zip
    gnused
    gnugrep
    psmisc
    opencl-headers

  ]
  ++ qt5Deps pkgs
  ++ qt6Deps pkgs
  ++ gnomeDeps pkgs
  ++ extraPkgs pkgs
  ;

  multiPkgs = pkgs: with pkgs; [
    # Common
    libsndfile
    libtheora
    libogg
    libvorbis
    libopus
    libGLU
    libpcap
    libpulseaudio
    libao
    libevdev
    udev
    libgcrypt
    libxml2
    libusb1
    libpng
    libmpeg2
    libv4l
    libjpeg
    libxkbcommon
    libass
    libcdio
    libjack2
    libsamplerate
    libzip
    libmad
    libaio
    libcap
    libtiff
    libva
    libgphoto2
    libxslt
    libsndfile
    giflib
    zlib
    glib
    alsa-lib
    zziplib
    bash
    dbus
    keyutils
    zip
    cabextract
    freetype
    unzip
    coreutils
    readline
    gcc
    SDL
    SDL2
    curl
    graphite2
    gtk2
    gtk3
    udev
    ncurses
    wayland
    libglvnd
    vulkan-loader
    xdg-utils
    sqlite
    gnutls
    p11-kit
    libbsd
    harfbuzz

    # PCSX2 // TODO: "libgobject-2.0.so.0: wrong ELF class: ELFCLASS64"

    # WINE
    cups
    lcms2
    mpg123
    cairo
    unixodbc
    samba4
    sane-backends
    openldap
    ocl-icd
    util-linux
    libkrb5

    # Proton
    libselinux

    # Winetricks
    fribidi
    pango
  ]
  ++ xorgDeps pkgs
  ++ gstreamerDeps pkgs
  ++ extraLibraries pkgs
  ;
  
  extraInstallCommands = ''
    mkdir -p $out/share
    ln -sf ${twintaillauncher-unwrapped}/share/applications $out/share
    ln -sf ${twintaillauncher-unwrapped}/share/icons $out/share
  '';

  # allows for some gui applications to share IPC
  # this fixes certain issues where they don't render correctly
  unshareIpc = false;

  # Some applications such as Natron need access to MIT-SHM or other
  # shared memory mechanisms. Unsharing the pid namespace
  # breaks the ability for application to reference shared memory.
  unsharePid = false;
}
