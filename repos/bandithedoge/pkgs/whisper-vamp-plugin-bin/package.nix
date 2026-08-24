{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "whisper-vamp-plugin-bin";
  version = "4.0.0";
  src = fetchzip {
    url = "https://github.com/Ircam-Partiels/whisper-vamp-plugin/releases/download/${finalAttrs.version}/Whisper-Linux.tar.gz";
    sha256 = "sha256-dN/K5GLO7JsE5RDibSYl+wbA8goIIB5Ro54KN/77dW0=";
  };

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The Whisper Vamp plugin is an implementation of the Whisper speech recognition model developed by OpenAI as a Vamp plugin";
    homepage = "https://github.com/Ircam-Partiels/whisper-vamp-plugin";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
