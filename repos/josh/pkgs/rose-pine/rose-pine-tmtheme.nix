{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "rose-pine-tmtheme";
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "tm-theme";
    rev = "c4cab0c431f55a3c4f9897407b7bdad363bbb862";
    hash = "sha256-maQp4QTJOlK24eid7mUsoS7kc8P0gerKcbvNaxO8Mic=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rose-pine/tmtheme
    cp ./dist/themes/*.tmTheme $out/share/rose-pine/tmtheme/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Soho vibes for TextMate";
    homepage = "https://github.com/rose-pine/tm-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
