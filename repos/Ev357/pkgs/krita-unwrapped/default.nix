{
  mkDerivation,
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  karchive,
  kconfig,
  kwidgetsaddons,
  kcompletion,
  kcoreaddons,
  kguiaddons,
  ki18n,
  kitemmodels,
  kitemviews,
  kwindowsystem,
  kio,
  kcrash,
  breeze-icons,
  boost,
  libraw,
  fftw,
  eigen,
  exiv2,
  fribidi,
  libaom,
  libheif,
  lcms2,
  gsl,
  openexr,
  giflib,
  libjxl,
  mlt,
  openjpeg,
  opencolorio,
  xsimd,
  poppler,
  curl,
  ilmbase,
  immer,
  kseexpr,
  lager,
  libmypaint,
  libunibreak,
  libwebp,
  qtmultimedia,
  qtx11extras,
  quazip,
  SDL2,
  zug,
  pkg-config,
  python3Packages,
  qtquickcontrols2,
  wayland,
  wayland-protocols,
  libxkbcommon,
  writeScript,
}:
mkDerivation rec {
  pname = "krita-unwrapped";
  version = "5.3.0-prealpha";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "graphics";
    repo = "krita";
    rev = "db9704829ea1b0a3a5591a5ba1b4d8142d8125a0";
    hash = "sha256-Q9T/2GSsNs+uqb6flrVCb1j0K6sOgiYjBKC7CIoolIU=";
  };

  passthru.updateScript =
    writeScript "update-${pname}"
    # bash
    ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts

      set -eu -o pipefail

      REV="$(curl -s "https://invent.kde.org/api/v4/projects/206/repository/commits/master" | jq -r '.id')"
      update-source-version ${pname} "${version}" --ignore-same-version --rev="$REV"
    '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    python3Packages.sip
  ];

  buildInputs = [
    karchive
    kconfig
    kwidgetsaddons
    kcompletion
    kcoreaddons
    kguiaddons
    ki18n
    kitemmodels
    kitemviews
    kwindowsystem
    kio
    kcrash
    breeze-icons
    boost
    libraw
    fftw
    eigen
    exiv2
    fribidi
    lcms2
    gsl
    openexr
    lager
    libaom
    libheif
    giflib
    libjxl
    mlt
    openjpeg
    opencolorio
    xsimd
    poppler
    curl
    ilmbase
    immer
    kseexpr
    libmypaint
    libunibreak
    libwebp
    qtmultimedia
    qtx11extras
    quazip
    SDL2
    zug
    python3Packages.pyqt5
    qtquickcontrols2
    wayland
    wayland-protocols
    libxkbcommon
  ];

  env.NIX_CFLAGS_COMPILE = toString (lib.optional stdenv.cc.isGNU "-Wno-deprecated-copy");

  postPatch = let
    pythonPath = python3Packages.makePythonPath (
      with python3Packages; [
        sip
        setuptools
      ]
    );
  in ''
    substituteInPlace cmake/modules/FindSIP.cmake \
      --replace 'PYTHONPATH=''${_sip_python_path}' 'PYTHONPATH=${pythonPath}'
    substituteInPlace cmake/modules/SIPMacros.cmake \
      --replace 'PYTHONPATH=''${_krita_python_path}' 'PYTHONPATH=${pythonPath}'

    substituteInPlace plugins/impex/jp2/jp2_converter.cc \
      --replace '<openjpeg.h>' '<${openjpeg.incDir}/openjpeg.h>'
  '';

  cmakeBuildType = "RelWithDebInfo";

  cmakeFlags = [
    "-DPYQT5_SIP_DIR=${python3Packages.pyqt5}/${python3Packages.python.sitePackages}/PyQt5/bindings"
    "-DPYQT_SIP_DIR_OVERRIDE=${python3Packages.pyqt5}/${python3Packages.python.sitePackages}/PyQt5/bindings"
    "-DBUILD_KRITA_QT_DESIGNER_PLUGINS=ON"
  ];

  meta = {
    description = "Free and open source painting application";
    homepage = "https://krita.org/";
    mainProgram = "krita";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
