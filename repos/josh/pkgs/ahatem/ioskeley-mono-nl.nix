{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono-nl";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono-NL.zip";
    stripRoot = false;
    hash = "sha256-3zqO7W23Zcdz7L8cO0A8oAH0PQqYUNwKiKnAmN/Ja8s=";
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
    files = runCommand "test-ioskeley-mono-nl-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNL-Regular.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNL-Bold.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNL-Italic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNL-BoldItalic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNL-SemiCondensed.ttf
      touch $out
    '';

    family = runCommand "test-ioskeley-mono-nl-family" { nativeBuildInputs = [ fontconfig ]; } ''
      fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
        tr ',' '\n' | sort -u >families.txt
      grep -qx 'Ioskeley Mono NL' families.txt
      touch $out
    '';
  };

  meta = {
    description = "Ioskeley Mono with ligatures disabled";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
