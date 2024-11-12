{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  alsa-lib,
  asmjit,
  clap,
  curl,
  freeglut,
  freetype,
  gtk3-x11,
  jack2,
  lerc,
  libGL,
  libdatrie,
  libepoxy,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libtiff,
  libxkbcommon,
  mesa,
  pcre2,
  pkg-config,
  sqlite,
  util-linux,
  webkitgtk,
  xorg,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "gearmulator";
  version = "1.3.21-master";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-CMyqCtf/7HQtEHa5Q9eTRhon52A4Wp6jiU7ZYDV/sr0=";
    owner = "dsp56300";
    repo = "gearmulator";
    rev = "6a23597123f922b6a4e5994069fc3175e89b5ee2";
    # rev = "${version}";
  };

  nativeBuildInputs = [
    cmake
    asmjit
    libsysprof-capture
    pkg-config
    unzip
  ];

  buildInputs = [
    clap
    alsa-lib
    curl
    freeglut
    freetype
    gtk3-x11
    jack2
    lerc
    libGL
    libdatrie
    libepoxy
    libselinux
    libsepol
    libthai
    libtiff
    libxkbcommon
    mesa
    pcre2
    sqlite
    util-linux
    webkitgtk
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXtst
  ];

  cmakeFlags = [
    # "-Dgearmulator_BUILD_FX_PLUGIN=ON"  # DEFAULT: OFF
    "-Dgearmulator_BUILD_JUCEPLUGIN_LV2=OFF" # DEFAULT: ON
    # "-Dgearmulator_SYNTH_NODALRED2X=OFF"  # DEFAULT: ON
    # "-Dgearmulator_SYNTH_OSIRUS=OFF"  # DEFAULT: ON
    # "-Dgearmulator_SYNTH_OSTIRUS=OFF"  # DEFAULT: ON
    # "-Dgearmulator_SYNTH_VAVRA=OFF"  # DEFAULT: ON
    # "-Dgearmulator_SYNTH_XENIA=OFF"  # DEFAULT: ON
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst,vst3}/dsp56300
    cp -rt $out/lib/clap/dsp56300 ../bin/plugins/Release/CLAP/{NodalRed2x.clap,Osirus.clap,OsTIrus.clap,Vavra.clap,Xenia.clap}
    cp -rt $out/lib/vst/dsp56300 ../bin/plugins/Release/VST/{libNodalRed2x.so,libOsirus.so,libOsTIrus.so,libVavra.so,libXenia.so}
    cp -rt $out/lib/vst3/dsp56300 ../bin/plugins/Release/VST3/{NodalRed2x.vst3,Osirus.vst3,OsTIrus.vst3,Vavra.vst3,Xenia.vst3}

    runHook postInstall
  '';

  meta = {
    description = "Emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs";
    homepage = "https://github.com/dsp56300/gearmulator";
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
}
