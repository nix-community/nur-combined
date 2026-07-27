{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  fftwFloat,
  glibmm,
  juceCmakeHook,
  libsigcxx,
  libsndfile,
  lilv,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.guitarix-vst-bin) pname src;
  version = lib.removePrefix "v" sources.guitarix-vst-bin.version;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    fftwFloat
    glibmm
    libsigcxx
    libsndfile
    lilv
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3
    cp -r Guitarix.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "guitarix vst3 wrapper for linux";
    homepage = "https://github.com/brummer10/guitarix.vst";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
