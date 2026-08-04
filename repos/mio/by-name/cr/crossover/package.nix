{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "crossover";
  version = "26.3.0";

  src = fetchurl {
    url = "https://media.codeweavers.com/pub/crossover/cxmac/demo/crossover-${finalAttrs.version}.zip";
    hash = "sha256-hojghIxOX3nxzDUctS0yRH2gDGwAz9O0uy0WTURYmiY=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  # Avoid rewriting signed Mach-O binaries in the .app bundle.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -R CrossOver.app $out/Applications/

    makeWrapper "$out/Applications/CrossOver.app/Contents/MacOS/CrossOver" \
      $out/bin/crossover

    runHook postInstall
  '';

  meta = {
    description = "Run Windows software on macOS without a virtual machine";
    homepage = "https://www.codeweavers.com/products/crossover-mac/";
    downloadPage = "https://www.codeweavers.com/crossover/download";
    changelog = "https://www.codeweavers.com/crossover/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.darwin;
    mainProgram = "crossover";
  };
})
