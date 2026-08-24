{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "maim-bin";
  version = "1.1.1";
  src = fetchzip {
    url = "https://github.com/ArdenButterfield/Maim/releases/download/v${finalAttrs.version}/Maim-${finalAttrs.version}-Linux.zip";
    sha256 = "sha256-2AoM5p9qP66bPceQEyWDFlLOOsH8e7dspyy3Lhz6EP8=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst3}
    cp Standalone/Maim $out/bin
    cp -r VST3/Maim.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Audio plugin for custom MP3 distortion and digital glitches";
    homepage = "https://github.com/ArdenButterfield/Maim";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Maim";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
