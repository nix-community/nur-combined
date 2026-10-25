{
  lib,
  buildFHSEnv,
  twintaillauncher-unwrapped,
  extraPkgs ? pkgs: [ ],
  extraLibraries ? pkgs: [ ],
}:

let
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

    # WINE
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
}
