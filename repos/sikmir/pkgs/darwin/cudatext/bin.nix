{ lib, stdenv, fetchurl, _7zz, makeWrapper, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.208.0.0";

  src = {
    "aarch64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
      hash = "sha256-w7ypX5tYtAXaEaJgKXqhgH+ORw3yUSg0lOS3RG4lTbY=";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
      hash = "sha256-PBYqfF73/tJ2eHfNWJ5LkjOmqkEQS+Fn/lh5ipNzajU=";
    };
  }.${stdenv.hostPlatform.system};

  sourceRoot = ".";

  # APFS format is unsupported by undmg
  nativeBuildInputs = [ _7zz makeWrapper ];
  unpackCmd = "7zz x $curSrc";

  installPhase = ''
    runHook preInstall

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
