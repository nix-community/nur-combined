{
  sources,

  lib,
  stdenv,
}:
let
  source = sources."zine-bin-${stdenv.targetPlatform.system}" or sources.zine-bin-x86_64-linux;
in
stdenv.mkDerivation {
  pname = "zine-bin";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;
  sourceRoot = ".";

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    chmod +x zine
    cp zine $out/bin

    runHook postBuild
  '';

  meta = {
    description = "Fast, Scalable, Flexible Static Site Generator (SSG)";
    homepage = "https://zine-ssg.io";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "zine-bin";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
