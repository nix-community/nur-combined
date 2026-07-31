{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rose-pine-tmtheme";
  version = "0-unstable-2026-06-22";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "tm-theme";
    rev = "6d556734541ccb04172e81fd58de4a35fff72d19";
    hash = "sha256-5+fG21KbB7bdPvszkz9Ftl6fCDGs17fJNTAXFRFWZGo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rose-pine/tmtheme
    cp ./dist/*.tmTheme $out/share/rose-pine/tmtheme/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    files = runCommand "test-rose-pine-tmtheme-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/rose-pine/tmtheme/rose-pine.tmTheme
      test -s ${finalAttrs.finalPackage}/share/rose-pine/tmtheme/rose-pine-moon.tmTheme
      test -s ${finalAttrs.finalPackage}/share/rose-pine/tmtheme/rose-pine-dawn.tmTheme
      touch $out
    '';
  };

  meta = {
    description = "Soho vibes for TextMate";
    homepage = "https://github.com/rose-pine/tm-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
