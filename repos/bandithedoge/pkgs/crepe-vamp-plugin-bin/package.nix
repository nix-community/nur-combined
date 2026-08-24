{
  fetchzip,
  lib,
  stdenv,
  nix-update-script,

  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "crepe-vamp-plugin-bin";
  version = "3.0.0";
  src = fetchzip {
    url = "https://github.com/Ircam-Partiels/crepe-vamp-plugin/releases/download/${finalAttrs.version}/Crepe-Linux.tar.gz";
    sha256 = "sha256-dIFwxJN43dptdpp1jGChUyl9k06sC+L9ZpeXAZBXPeo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vamp
    cp ircamcrepe.* $out/lib/vamp

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
