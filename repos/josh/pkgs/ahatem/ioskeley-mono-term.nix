{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono-term";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono-Term.zip";
    stripRoot = false;
    hash = "sha256-Ei6cRAMC9C62X8coHsTMvfPZfloiUp+A4HeT89df3pk=";
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
    files = runCommand "test-ioskeley-mono-term-files" { } ''
      count=0
      for f in ${finalAttrs.finalPackage}/share/fonts/truetype/*.ttf; do
        test -s "$f"
        count=$((count + 1))
      done
      test "$count" -eq 40
      touch $out
    '';

    family = runCommand "test-ioskeley-mono-term-family" { nativeBuildInputs = [ fontconfig ]; } ''
      fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
        tr ',' '\n' | sort -u >families.txt
      grep -qx 'Ioskeley Mono Term' families.txt
      touch $out
    '';
  };

  meta = {
    description = "Ioskeley Mono with terminal spacing";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
