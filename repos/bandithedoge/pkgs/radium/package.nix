{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  ladspaPlugins,
  minimal-bootstrap,
  alsa-lib,
  binutils,
  boost,
  breakpointHook,
  cmake,
  dos2unix,
  fftw,
  fftwFloat,
  git,
  guile,
  ladspa-header,
  libGLU,
  libbfd,
  libiberty,
  libjack2,
  liblo,
  libpthread-stubs,
  libsamplerate,
  libsndfile,
  libuuid,
  libvorbis,
  libxcursor,
  libxinerama,
  libxrandr,
  lrdf,
  ncurses,
  pkg-config,
  qt6,
  speex,
  uutils-coreutils-noprefix,
  vst2-sdk,
  which,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "radium";
  version = "7.5.78-unstable-2026-08-24";
  src = fetchFromGitHub {
    owner = "kmatheussen";
    repo = "radium";
    rev = "12dd08848751644f2f764b12706a72f71667d7b1";
    hash = "sha256-5W9EnPNEPcHWcygZ+09QGlGjfjwJbdbWh2+t3EmX0NA=";
  };

  patches = [ ./static-libbfd.patch ];

  nativeBuildInputs = [
    breakpointHook
    cmake
    dos2unix
    git
    guile
    makeWrapper
    pkg-config
    qt6.qtshadertools
    uutils-coreutils-noprefix # arch
    which
  ];

  buildInputs = [
    alsa-lib
    boost
    fftwFloat
    ladspa-header
    libGLU
    libbfd
    libiberty
    libjack2
    liblo
    libpthread-stubs
    libsamplerate
    libsndfile
    libuuid
    libvorbis
    libxcursor
    libxinerama
    libxrandr
    lrdf
    qt6.qt5compat
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    speex
  ];

  dontWrapQtApps = true;
  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild

    patchShebangs .
    substituteInPlace Makefile \
      --replace-fail "/usr/bin/env bash" "${stdenv.shell}"

    cd bin/packages
    PYTHONEXE_NOT_AVAILABLE_YET=1 ./build.sh
    cd ../..
    ./build_linux.sh -j `nproc`

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,libexec}

    ./install.sh $out/libexec

    rm $out/libexec/radium/ladspa
    mkdir $out/libexec/radium/ladspa
    cp -r ${ladspaPlugins}/lib/ladspa/* $out/libexec/radium/ladspa
    cp ladspa_info/* $out/libexec/radium/ladspa

    makeWrapper $out/libexec/radium/radium $out/bin/radium \
      --set QT_QPA_PLATFORM_PLUGIN_PATH $(qmake -query QT_INSTALL_PLUGINS)

    runHook postInstall
  '';

  dontStrip = true; # https://github.com/kmatheussen/radium/issues/1153#issuecomment-421543245

  hardeningDisable = [ "format" ];

  env = {
    # makefile
    SHELL = stdenv.shell;
    PREFIX = placeholder "out";
    BUILDTYPE = "RELEASE";
    CCC = lib.getExe' stdenv.cc "c++";
    CC = lib.getExe' stdenv.cc "cc";
    LINKER = lib.getExe' stdenv.cc "ld";
    RADIUM_VST2SDK_PATH = vst2-sdk;
    # WARNINGS_AS_ERRORS = 0;

    # configuration.sh
    RADIUM_USE_CLANG = if stdenv.cc.isClang then 1 else 0;
    INCLUDE_FAUSTDEV_BUT_NOT_LLVM = 1;
    # TODO: remove these
    USE_QSVGVIEWER = 1;
    INCLUDE_PDDEV = 0;

    # bin/packages
    CMAKE_POLICY_VERSION_MINIMUM = "3.5";
    RADIUM_BUILD_LIBXCB = 0;

    # build_python27.sh
    MY_CC = lib.getExe' stdenv.cc "cc";
    MY_CPP = lib.getExe' stdenv.cc "c++";
  };

  NIX_CFLAGS_COMPILE = [
    "-std=gnu17"
    "-Wno-error"
    "-Wno-implicit-function-declaration"
    "-Wno-int-conversion"
    "-D_DEFAULT_SOURCE"
    "-L${lib.getLib fftwFloat}/lib"
    "-L${lib.getLib fftw}/lib"
    "-I${qt6.qttools}/include/QtUiTools"
    "-L${lib.getLib ncurses}/lib"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };

  meta = {
    description = "Music editor with a new type of interface";
    homepage = "https://www.radium.dog";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "radium";
    maintainers = [ lib.maintainers.bandithedoge ];
    broken = true;
  };
})
