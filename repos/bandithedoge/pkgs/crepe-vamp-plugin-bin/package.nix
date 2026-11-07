{
  fetchzip,
  lib,
  stdenv,
  nix-update-script,

  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "crepe-vamp-plugin-bin";
  version = "4.1.0";
  src = fetchzip {
    url = "https://github.com/Ircam-Partiels/crepe-vamp-plugin/releases/download/${finalAttrs.version}/Crepe-Vamp-Linux.zip";
    sha256 = "sha256-AIIxsXtp3cgQ1CC+AFbplOvznY0nu28cP0ANvrGG9vI=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vamp
    cp -r source $out/lib/vamp/ircamcrepe.vamp

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The Crepe plugin is an implementation of the CREPE monophonic pitch tracker, based on a deep convolutional neural network operating directly on the time-domain waveform input, as a Vamp plugin";
    homepage = "https://github.com/Ircam-Partiels/crepe-vamp-plugin";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
