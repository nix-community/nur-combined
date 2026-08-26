{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "lovelace-big-slider-card";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "nicufarmache";
    repo = "lovelace-big-slider-card";
    rev = version;
    hash = "sha256-SY0QyPDr5ptbdDJ2l2/r+2wLndEzXZejOIxhgUTVvQ4=";
  };

  passthru = {
    entrypoint = "big-slider-card.js";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./dist/big-slider-card.js $out/

    runHook postInstall
  '';

  npmDepsHash = "sha256-dQvzhKsw7i4cYeiYgQ2hRKU7S0ax39+s8FerbVGM1F0=";

  meta = {
    description = "A card with a big slider for light entities in Home Assistant";
    homepage = "https://github.com/nicufarmache/lovelace-big-slider-card";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lovelace-big-slider-card";
    platforms = lib.platforms.all;
  };
}
