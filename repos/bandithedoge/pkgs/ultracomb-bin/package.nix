{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcb,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ultracomb-bin";
  version = "0.4.1";
  src = fetchzip {
    url = "https://github.com/Wasaka0/ultracomb/releases/download/${finalAttrs.version}/ubuntu-${finalAttrs.version}.zip";
    sha256 = "sha256-2QqUUw5puXyfnas7Uay46mDKOite8i46FTkiOY9BcqM=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libGL
    libx11
    libxcb
    stdenv.cc.cc.lib
    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp Ultracomb.clap $out/lib/clap
    cp -r Ultracomb.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VST3/CLAP plugin that combines a flanger, phaser and frequency shifter to produce frequency notches that move around";
    homepage = "https://github.com/Wasaka0/ultracomb";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
