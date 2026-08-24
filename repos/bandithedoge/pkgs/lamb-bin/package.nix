{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  libxcb-wm,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lamb-bin";
  version = "2.1.0";
  src = fetchzip {
    url = "https://github.com/magnetophon/lamb-rs/releases/download/v${finalAttrs.version}/lamb-v${finalAttrs.version}-ubuntu-20.04.zip";
    hash = "sha256-2xQBDxmCilO0sl1J9N6ue/rZC8OOvhp0/khiJ7bJz0o=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    alsa-lib
    libGL
    libx11
    libxcb
    libxcb-wm
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/vst3}
    cp lamb $out/bin
    cp lamb.clap $out/lib/clap
    cp -r lamb.vst3 $out/lib/vst3

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A lookahead compressor/limiter that's soft as a lamb";
    homepage = "https://github.com/magnetophon/lamb-rs";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "lamb";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
