{ lib, stdenv, fetchurl, undmg, makeWrapper, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.195.0.5";

  src = {
    "aarch64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
      hash = "sha256-GMaqPnSEjzENcNpFi7YF5qENyk/sDEHCU/Xk/hYQtrQ=";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
      hash = "sha256-pNwpTACaK/tpA2bcZa0QyAndbT/r2aLomfynNibJcH4=";
    };
  }.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ undmg makeWrapper ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/CudaText.app/Contents/MacOS,bin}/cudatext

    runHook postInstall
  '';

  meta = with lib; {
    inherit (cudatext.meta) description homepage changelog license;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
})
