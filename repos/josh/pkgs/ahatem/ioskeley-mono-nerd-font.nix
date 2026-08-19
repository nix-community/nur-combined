{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono-nerd-font";
  version = "2.1.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono-NerdFont.zip";
    stripRoot = false;
    hash = "sha256-b0mqhLeDT+uYPYiOKB+cxc5M1TtFkICKAmlcmW3IjDg=";
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
    files = runCommand "test-ioskeley-mono-nerd-font-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNerdFontMono-Regular.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNerdFontMono-Bold.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNerdFontMono-Italic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNerdFontMono-BoldItalic.ttf
      test -s ${finalAttrs.finalPackage}/share/fonts/truetype/IoskeleyMonoNerdFontMono-SemiCondensed.ttf
      touch $out
    '';

    family = runCommand "test-ioskeley-mono-nerd-font-family" { nativeBuildInputs = [ fontconfig ]; } ''
      fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
        tr ',' '\n' | sort -u >families.txt
      grep -qx 'IoskeleyMono Nerd Font Mono' families.txt
      touch $out
    '';
  };

  meta = {
    description = "Ioskeley Mono patched with Nerd Font glyphs";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
