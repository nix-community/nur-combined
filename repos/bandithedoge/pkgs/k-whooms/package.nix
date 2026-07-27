{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  cairo,
  expat,
  freetype,
  glib,
  harfbuzz,
  libice,
  libsm,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxext,
  libxkbcommon,
  pango,
}:
stdenv.mkDerivation {
  inherit (sources.k-whooms) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    cairo
    expat
    freetype
    glib
    harfbuzz
    libice
    libsm
    libx11
    libxcb
    libxcb-cursor
    libxcb-keysyms
    libxext
    libxkbcommon
    pango
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3 $out/share/vst3
    cp -r K-Whooms.vst3 $out/lib/vst3
    cp -r presets $out/share/vst3

    runHook postBuild
  '';

  meta = {
    description = "Get K-Whooms and squeeze the fattest sounds out of it with just a few turns of the controls";
    homepage = "https://www.hansen-audio.org/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
