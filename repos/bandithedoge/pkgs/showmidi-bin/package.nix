{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "showmidi-bin";
  version = "1.0.1";
  src = fetchzip {
    url = "https://github.com/gbevin/ShowMIDI/releases/download/${finalAttrs.version}/ShowMIDI-Linux-Ubuntu-23.10-x64-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-AcchQe2UAzDc9Ov3NswdpLzuZM+QVYI4AfmQSFdxDSM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3}
    cp ShowMIDI $out/bin
    cp clap/ShowMIDI.clap $out/lib/clap
    cp -r lv2/ShowMIDI.lv2 $out/lib/lv2
    cp -r vst3/ShowMIDI.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-platform GUI application to effortlessly visualize MIDI activity";
    homepage = "https://github.com/gbevin/ShowMIDI";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ShowMIDI";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
