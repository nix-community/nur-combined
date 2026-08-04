{
  lib,
  stdenvNoCC,
  fetchzip,
  fontconfig,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ioskeley-mono-nl-nerd-font";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/ahatem/IoskeleyMono/releases/download/v${finalAttrs.version}/IoskeleyMono-NL-NerdFont.zip";
    stripRoot = false;
    hash = "sha256-N7mtM/aQwps77u907z8Rop3RftRGR4K8zDXFX8xWq5w=";
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
    files = runCommand "test-ioskeley-mono-nl-nerd-font-files" { } ''
      count=0
      for f in ${finalAttrs.finalPackage}/share/fonts/truetype/*.ttf; do
        test -s "$f"
        count=$((count + 1))
      done
      test "$count" -eq 60
      touch $out
    '';

    family =
      runCommand "test-ioskeley-mono-nl-nerd-font-family" { nativeBuildInputs = [ fontconfig ]; }
        ''
          fc-scan --format '%{family}\n' ${finalAttrs.finalPackage}/share/fonts/truetype |
            tr ',' '\n' | sort -u >families.txt
          grep -qx 'IoskeleyMonoNL Nerd Font' families.txt
          touch $out
        '';
  };

  meta = {
    description = "Ioskeley Mono with ligatures disabled, patched with Nerd Font glyphs";
    homepage = "https://github.com/ahatem/IoskeleyMono";
    license = lib.licenses.ofl;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
