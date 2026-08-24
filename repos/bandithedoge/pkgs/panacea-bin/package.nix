{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  csound6,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "panacea-bin";
  version = "1.0.1";
  src = fetchzip {
    url = "https://github.com/consint/Panacea/releases/download/v${finalAttrs.version}/Panacea_v${finalAttrs.version}_Linux_vst.zip";
    sha256 = "sha256-aStHjYIox00Y75ep/bfa/lnKxIxg5fFuw/YUnC6iVJY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    csound6
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst/Panacea

    cp Panacea.so Panacea.csd $out/lib/vst/Panacea
    cp -r img $out/lib/vst/Panacea

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Panacea is an autopan audio effect plugin with the possibility of humanization";
    homepage = "https://github.com/consint/Panacea";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
