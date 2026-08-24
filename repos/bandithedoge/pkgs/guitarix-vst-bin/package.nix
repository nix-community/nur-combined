{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  fftwFloat,
  glibmm,
  juceCmakeHook,
  libsigcxx,
  libsndfile,
  lilv,
  breakpointHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "guitarix-vst-bin";
  version = "0.5";
  src = fetchzip {
    url = "https://github.com/brummer10/guitarix.vst/releases/download/v${finalAttrs.version}/Guitarix.vst3.zip";
    sha256 = "sha256-yCUu3tOVsBJWWg8BmH2istpbfG0+ir0aY+VMTDmTAGc=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    breakpointHook
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "guitarix vst3 wrapper for linux";
    homepage = "https://github.com/brummer10/guitarix.vst";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
