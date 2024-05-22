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
  version = "1.214.0.0";

  src =
    {
      "aarch64-darwin" = fetchurl {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
        hash = "sha256-DU2QtKjPsHBw8hBb2t7cmYvUQ3UodgcW4Hp9kEyEzBI=";
      };
      "x86_64-darwin" = fetchurl {
        url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
        hash = "sha256-oGmUcPmnlqKn4mGVhbnFjM1FJ7H3uUg9Z7MKvt2By2Y=";
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

  meta = with lib; {
    inherit (cudatext.meta)
      description
      homepage
      changelog
      license
      ;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
})
