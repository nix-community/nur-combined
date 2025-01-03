{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "lovelace-big-slider-card";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "nicufarmache";
    repo = "lovelace-big-slider-card";
    rev = version;
    hash = "sha256-V0lYPI15uGakQhNDVhTy4sTTScn+PfaztRCb6lTAGh0=";
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

  npmDepsHash = "sha256-vOKkh2gO/YeEyS3BDWDJdQWy1sZzXPAF4PEi7IJ8bE8=";
  
  meta = {
    description = "A card with a big slider for light entities in Home Assistant";
    homepage = "https://github.com/nicufarmache/lovelace-big-slider-card";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lovelace-big-slider-card";
    platforms = lib.platforms.all;
  };
}
