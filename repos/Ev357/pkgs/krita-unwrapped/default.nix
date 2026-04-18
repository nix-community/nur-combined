{
  stdenv,
  SDL2,
  boost,
  cmake,
  curl,
  eigen,
  eigen_5 ? eigen,
  exiv2,
  fftw,
  fribidi,
  giflib,
  gsl,
  immer,
  kseexpr,
  lager,
  lcms2,
  lib,
  libaom,
  libheif,
  libjxl,
  libmypaint,
  libraw,
  qt6,
  kdePackages,
  libunibreak,
  libwebp,
  opencolorio,
  openexr,
  openjpeg,
  pkg-config,
  python3Packages,
  xsimd,
  zug,
  fetchFromGitLab,
  wayland,
  wayland-protocols,
  libxkbcommon,
  writeScript,
}:
stdenv.mkDerivation rec {
  pname = "krita-unwrapped";
  version = "6.1.0-prealpha";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "graphics";
    repo = "krita";
    rev = "de23848e7e58b1c36c79f2c02138f748a439d47d";
    hash = "sha256-PmFfOWzKkWVyaEHeibxBfdMaztak4l8P10dUyejIfrY=";
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
    kdePackages.extra-cmake-modules
    pkg-config
    python3Packages.sip
    qt6.wrapQtAppsHook
  ];

  buildInputs =
    [
      boost
      libraw
      fftw
      eigen_5
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
      openjpeg
      opencolorio
      xsimd
      curl
      immer
      kseexpr
      libmypaint
      libunibreak
      libwebp
      SDL2
      zug
      python3Packages.pyqt6

      qt6.qtmultimedia
      qt6.qttools

      wayland
      wayland-protocols
      libxkbcommon
    ]
    ++ (with kdePackages; [
      breeze-icons
      karchive
      kcompletion
      kconfig
      kcoreaddons
      kcrash
      kguiaddons
      ki18n
      kio
      kitemmodels
      kitemviews
      kwidgetsaddons
      kwindowsystem
      mlt
      poppler
      quazip
      libkdcraw
    ]);

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
    "-DBUILD_WITH_QT6=ON"
    "-DALLOW_UNSTABLE=QT6"
    "-DENABLE_UPDATERS=OFF"
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
