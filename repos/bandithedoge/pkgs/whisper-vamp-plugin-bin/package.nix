{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation {
  inherit (sources.whisper-vamp-plugin-bin) pname version src;

  outputs = [
    "out"
    "lib"
  ];

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
    cp ircamwhisper.* $out/lib/vamp

    mkdir -p $lib/libexec
    cp *.bin $lib/libexec

    runHook postBuild
  '';

  meta = {
    description = "The Whisper Vamp plugin is an implementation of the Whisper speech recognition model developed by OpenAI as a Vamp plugin";
    homepage = "https://github.com/Ircam-Partiels/whisper-vamp-plugin";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
