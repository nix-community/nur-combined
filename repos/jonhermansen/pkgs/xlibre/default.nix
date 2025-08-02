{
  audit,
  autoconf,
  automake,
  buildFHSEnv,
  cmake,
  dbus,
  fetchurl,
  #  fetchFromGitHub,
  #  fetchFromGitLab,
  fop,
  freetype,
  xorg, # libX11,
  #xorg.libXau,
  #xorg.libXdmcp,
  lib,
  libGL,
  libGLU,
  libepoxy,
  libgbm,
  libunwind,
  libXfixes,
  libXfont2,
  libbsd,
  libdrm,
  libfontenc,
  libgcrypt,
  libglvnd,
  libpciaccess,
  libselinux,
  libxcb,
  libxkbfile,
  libxcvt,
  libxshmfence,
  libxslt,
  mesa,
  mesa-gl-headers,
  meson,
  ninja,
  openssl,
  pixman,
  pkg-config,
  pkgconf,
  stdenv,
  systemd,
  testers,
  xcbutil,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
  xf86inputlibinput,
  xkbcomp,
  xmlto,
  xorgproto,
  xtrans,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "xlibre";
  version = "25.0.0.4";

  src = fetchurl {
    url = "https://github.com/X11Libre/xserver/archive/refs/tags/xlibre-xserver-25.0.0.4.tar.gz";
    hash = "sha256-ORD1pfageIeIiF0PoBatooGCw/xFupHfg8/90rCd6jI=";
  };

  #  src = fetchFromGitHub {
  #    owner = "X11Libre";
  #    repo = "xserver";
  #    tag = "xlibre-xserver-${version}";
  #    hash = "sha256-toAAdwX1Y87eLvze+TAiuakN4r3Uj7NQMCYbOCS51ak=";
  #  };

  #  src2 = fetchFromGitHub {
  #    owner = "X11Libre";
  #    repo = "xf86-input-libinput";
  #    tag = "xlibre-xf86-input-libinput-1.5.0.1";
  #    hash = "sha256-fWVR/tFTPeA8Q6J9thpGOsLF5fYirtZ6SogU9T2yjiU=";
  #  };

  #hardeningDisable = [ "all" ];
  # hardeningDisable = [
  #   "bindnow"
  #   "relro"
  # ];
  strictDeps = true;
  #dontFixCmake = true;
  dontUseCmakeConfigure = true;
  nativeBuildInputs = [
    audit
    autoconf
    automake
    cmake
    dbus
    fop
    freetype
    #glib
    #gtk3
    libGL
    libGLU
    libbsd
    libdrm
    libepoxy
    libfontenc
    libgbm
    libgcrypt
    libglvnd
    libpciaccess
    libselinux
    libunwind
    libxcb
    libxcvt
    libxslt
    mesa
    mesa-gl-headers
    meson
    ninja
    openssl
    pixman
    pkg-config
    pkgconf
    systemd # udev
    #xf86inputlibinput
    xmlto
    xorg.fontutil
    xorg.libX11
    xorg.libXau
    xorg.libXdmcp
    xorg.libXext
    xorg.libXfixes
    xorg.libXfont
    xorg.libXfont2
    xorg.libxcvt
    xorg.libxkbfile
    xorg.libxshmfence
    xorg.pixman
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkbcomp
    xorg.xorgproto
    xorg.xorgsgmldoctools
    xorg.xtrans
    xorgproto
    zlib
  ];
  buildInputs = nativeBuildInputs; # JAH TODO: Break apart nativeBuildInputs vs buildInputs
  nativeLibs = buildInputs; # JAH TODO: Is this still needed?
  mesonFlags =
    let
      inherit (lib.strings) mesonEnable mesonOption;
    in
    [
      (mesonOption "docs" "false") # disabled docs because no network in sandbox
      (mesonOption "devel-docs" "false") # see comment above
      (mesonOption "glx" "false") # JAH TODO: need dri support
    ];
  #  postBuild = ''
  #    ls -al
  #    ls -al $src2/
  #    mkdir tmp2
  #    cp -R $src2 tmp2
  #    cd tmp2
  #    ./autogen.sh
  #    ./configure
  #    make
  #    exit 3
  #  '';
  #nativeBuildInputs = [ mesa ];
  # configurePhase = ''
  #   runHook preConfigure
  #   ls -al
  #   runHook postConfigure
  # '';
  # buildPhase = ''
  #   meson compile -C build
  #   #cd build
  #   #ninja
  # '';
  # checkPhase = ''
  #   # do nothing here
  # '';
  # installPhase = ''
  #   # do nothing here
  # '';
  #installCheckPhase = ''
  #  echo ${out}
  #'';
  meta = {
    description = "Alternative Xserver";
    longDescription = ''
      Xlibre is a fork of the Xorg Xserver with lots of code cleanups and
      enhanced functionality.
    '';
    homepage = "https://www.freelists.org/list/xlibre";
    changelog = "https://github.com/X11Libre/xserver/commits/xlibre-xserver-25.0.0.4/";
    license = lib.licenses.mit;
    mainProgram = "Xorg";
    platforms = lib.platforms.linux;
  };
  #targetPkgs = _: [
  #  xf86inputlibinput
  #  xorgserver
  #];
  #runScript = "/bin/startxlibre";
}
