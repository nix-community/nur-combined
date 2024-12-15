{
  lib,
  stdenv,
  fetchzip,
  _7zz,
  makeWrapper,
  cudatext,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.219.1.0";

  src =
    {
      "aarch64-darwin" = fetchzip {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg.zip";
        hash = "sha256-z2kVRTI7O8l+bhGwHTGH7pL4BUkldaGnMJbaMj7RGiU=";
        stripRoot = false;
      };
      "x86_64-darwin" = fetchzip {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg.zip";
        hash = "sha256-P5b845iNTyfwmaG3uUgvjCyyd0RqqBAvFPGWyfwZDls=";
        stripRoot = false;
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
