{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "whisper-vamp-plugin-bin";
  version = "5.0.0";
  src = fetchzip {
    url = "https://github.com/Ircam-Partiels/whisper-vamp-plugin/releases/download/${finalAttrs.version}/Whisper-Vamp-Linux.zip";
    sha256 = "sha256-5Ytoqmf4oHoIj38e6W6n1cCZiv+WfzMbIatcrRnK/n4=";
  };
  sourceRoot = ".";

  outputs = [
    "out"
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
    cp -r source $out/lib/vamp/ircamwhisper.vamp

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
