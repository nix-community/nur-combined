{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  makeWrapper,
  cudatext,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.216.6.0";

  src =
    {
      "aarch64-darwin" = fetchurl {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
        hash = "sha256-9IyvKHqR1G4JukQjoCBQMxp0y6M2v+aloX5ZcU2b7HY=";
      };
      "x86_64-darwin" = fetchurl {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
        hash = "sha256-QVjhJOGRyLkxDRxPKZ2d/TbXN0tDNcY7EZIx8/OnjPA=";
      };
    }
    .${stdenv.hostPlatform.system};

  sourceRoot = ".";

  # APFS format is unsupported by undmg
  nativeBuildInputs = [
    _7zz
    makeWrapper
  ];
  unpackCmd = "7zz x $curSrc";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/CudaText.app/Contents/MacOS,bin}/cudatext

    runHook postInstall
  '';

  meta = {
    inherit (cudatext.meta)
      description
      homepage
      changelog
      license
      ;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
