{
  sources,

  stdenv,
  lib,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.just-a-sample-bin) pname src;
  version = lib.removePrefix "v" (
    builtins.concatStringsSep "." (
      lib.takeEnd 3 (lib.splitString "." sources.just-a-sample-bin.version)
    )
  );
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3
    cp -r "Just a Sample.vst3" $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "Just a Sample is a modern, open-source audio sampler";
    homepage = "https://bobona.github.io/just-a-sample/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
