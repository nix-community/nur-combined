{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono-term-nerd-font";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono-Term-NerdFont.zip";
    stripRoot = false;
    hash = "sha256-joAhNADErBErDqTrNelJ0ulGZCN/OUZ1SMYyU++7l6U=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 */*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex=^v([0-9][0-9.]*)$"
    ];
  };

  passthru.tests = {
    files = runCommand "test-ioskeley-mono-term-nerd-font-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoTermNerdFontMono-Regular.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoTermNerdFontMono-Bold.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoTermNerdFontMono-Italic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoTermNerdFontMono-BoldItalic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoTermNerdFontMono-SemiCondensed.ttf
      touch $out
    '';

    family =
      runCommand "test-ioskeley-mono-term-nerd-font-family" { nativeBuildInputs = [ fontconfig ]; }
        ''
          fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
            tr ',' '\n' | sort -u >families.txt
          grep -qx 'IoskeleyMonoTerm Nerd Font Mono' families.txt
          touch $out
        '';
  };

  meta = {
    description = "Ioskeley Mono with terminal spacing, patched with Nerd Font glyphs";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
