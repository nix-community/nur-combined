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
  # fxPlugins ? false,
  # lv2Plugins ? false,
  nodalRed2xPlugin ? true,
  osirusPlugin ? true,
  osTIrusPlugin ? true,
  vavraPlugin ? true,
  xeniaPlugin ? true,

}:
stdenv.mkDerivation rec {
  pname = "gearmulator";
  version = "1.4.4";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-/fO3weXuw5wa1OR46zAxi6S6vie7xcue1vJW2J8GIZg=";
    owner = "dsp56300";
    repo = "gearmulator";
    rev = "${version}";
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

  cmakeFlags =
    # lib.optional fxPlugins "-Dgearmulator_BUILD_FX_PLUGIN=ON"
    # ++ lib.optional (!lv2Plugins) "-Dgearmulator_BUILD_JUCEPLUGIN_LV2=OFF"
    lib.optional (!nodalRed2xPlugin) "-Dgearmulator_SYNTH_NODALRED2X=OFF"
    ++ lib.optional (!osirusPlugin) "-Dgearmulator_SYNTH_OSIRUS=OFF"
    ++ lib.optional (!osTIrusPlugin) "-Dgearmulator_SYNTH_OSTIRUS=OFF"
    ++ lib.optional (!vavraPlugin) "-Dgearmulator_SYNTH_VAVRA=OFF"
    ++ lib.optional (!xeniaPlugin) "-Dgearmulator_SYNTH_XENIA=OFF";

  installPhase =
    let
      # lv2 = lib.optionalString lv2Plugins ",lv2";
      NodalRed2x = lib.optionalString nodalRed2xPlugin "NodalRed2x";
      Osirus = lib.optionalString osirusPlugin "NodalRed2x";
      OsTIrus = lib.optionalString osTIrusPlugin "OsTIrus";
      Vavra = lib.optionalString vavraPlugin "Vavra";
      Xenia = lib.optionalString xeniaPlugin "Xenia";
    in
    ''
      runHook preInstall

      mkdir -p $out/lib/{clap,lv2,vst,vst3}

      for plugin in ${NodalRed2x} ${Osirus} ${OsTIrus} ${Vavra} ${Xenia}; do
        cp -t "$out/lib/clap"  "../bin/plugins/Release/CLAP/$plugin.clap"
        # cp -t "$out/lib/lv2"   "../bin/plugins/Release/LV2/$plugin.lv2"
        cp -t "$out/lib/vst"   "../bin/plugins/Release/VST/lib$plugin.so"
        cp -rt "$out/lib/vst3"  "../bin/plugins/Release/VST3/$plugin.vst3"
      done

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
