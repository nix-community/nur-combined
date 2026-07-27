{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation {
  inherit (sources.crepe-vamp-plugin-bin) pname version src;

  preferLocalBuild = true;

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

  meta = {
    description = "The Crepe plugin is an implementation of the CREPE monophonic pitch tracker, based on a deep convolutional neural network operating directly on the time-domain waveform input, as a Vamp plugin";
    homepage = "https://github.com/Ircam-Partiels/crepe-vamp-plugin";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
