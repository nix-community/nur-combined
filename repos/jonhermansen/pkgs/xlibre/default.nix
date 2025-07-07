{
  audit,
  autoconf,
  automake,
  buildFHSEnv,
  cmake,
  dbus,
  fetchFromGitHub,
  fetchFromGitLab,
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

stdenv.mkDerivation (finalAttrs: {
  pname = "xlibre";
  version = "25.0.0.4";

  src = fetchFromGitHub {
    owner = "X11Libre";
    repo = "xserver";
    tag = "xlibre-xserver-${finalAttrs.version}";
    hash = "sha256-toAAdwX1Y87eLvze+TAiuakN4r3Uj7NQMCYbOCS51ak=";
  };

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
  buildInputs = finalAttrs.nativeBuildInputs; # JAH TODO: Break apart nativeBuildInputs vs buildInputs
  nativeLibs = finalAttrs.buildInputs; # JAH TODO: Is this still needed?
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
  #  echo ${finalAttrs}.out
  #'';
  meta = {
    license = lib.licenses.mit;
    #sourceProvenance = lib.sourceTypes.fromSource;
  };
  #targetPkgs = _: [
  #  xf86inputlibinput
  #  xorgserver
  #];
  #runScript = "/bin/startxlibre";
})
