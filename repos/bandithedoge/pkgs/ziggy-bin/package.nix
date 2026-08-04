{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
}:
let
  source = sources."ziggy-bin-${stdenv.system}" or sources.ziggy-bin-x86_64-linux;
in
stdenv.mkDerivation {
  pname = "ziggy-bin";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    cp $src $out/bin/ziggy

    runHook postBuild
  '';

  meta = {
    description = "Data serialization language for expressing clear API messages, config files, etc.";
    homepage = "https://ziggy-lang.io/";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ziggy";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
