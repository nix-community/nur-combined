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
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "open-mbc-bin";
  version = "0.2.2";
  src = fetchzip {
    url = "https://github.com/maor1993/open_mbc/releases/download/v${finalAttrs.version}/open_mbc-v${finalAttrs.version}-ubuntu-22.04.zip";
    sha256 = "sha256-D9BsxMeuxEuWsQxogDMiA74no6N4H3DJiAYjHhhxza8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    libGL
    libx11
    libxcb
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst3}
    cp "Open Mbc" $out/bin/OpenMbc
    chmod +x $out/bin/OpenMbc
    cp -r "Open Mbc.vst3" $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "multiband compressor vst";
    homepage = "https://github.com/maor1993/open_mbc";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "OpenMbc";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
