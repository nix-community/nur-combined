{ lib, stdenv, fetchurl, _7zz, unzip, makeWrapper, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.210.0.0";

  src = {
    "aarch64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg.zip";
      hash = "sha256-w7ypX5tYtAXaEaJgKXqhgH2ORw3yUSg0lOS3RG4lTbY=";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg.zip";
      hash = "sha256-9JQx1btljQ4/ybtEoBKQI00KOh9xp+7BEvuMhL2gKcw=";
    };
  }.${stdenv.hostPlatform.system};

  sourceRoot = ".";

  # APFS format is unsupported by undmg
  nativeBuildInputs = [ _7zz unzip makeWrapper ];

  installPhase = ''
    runHook preInstall

    7zz x *.dmg
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/CudaText.app/Contents/MacOS,bin}/cudatext

    runHook postInstall
  '';

  meta = with lib; {
    inherit (cudatext.meta) description homepage changelog license;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
})
