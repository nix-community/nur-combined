{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mxtune-bin";
  version = "1.2.0";
  src = fetchzip {
    url = "https://github.com/liuanlin-mx/MXTune/releases/download/v${finalAttrs.version}/ubuntu1804_x86_64_vst_v${finalAttrs.version}.zip";
    sha256 = "sha256-wdpX7JYBL5yr8sDvu9X4w1IOPmZPedw/a8xirpfwHTU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst
    cp mx_tune.so $out/lib/vst

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pitch correction plugin for VST";
    homepage = "https://github.com/liuanlin-mx/MXTune";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
