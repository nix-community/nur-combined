{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono.zip";
    stripRoot = false;
    hash = "sha256-1WGAPwbfSG3fpssUTnHCTVI8eKNHSHWHdfdq4JUQ9ls=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 */Hinted/*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex=^v([0-9][0-9.]*)$"
    ];
  };

  passthru.tests = {
    files = runCommand "test-ioskeley-mono-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMono-Regular.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMono-Bold.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMono-Italic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMono-BoldItalic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMono-SemiCondensed.ttf
      touch $out
    '';

    family = runCommand "test-ioskeley-mono-family" { nativeBuildInputs = [ fontconfig ]; } ''
      fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
        tr ',' '\n' | sort -u >families.txt
      grep -qx 'Ioskeley Mono' families.txt
      touch $out
    '';
  };

  meta = {
    description = "Free alternative to Berkeley Mono, built by configuring Iosevka";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
