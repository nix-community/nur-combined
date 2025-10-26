{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "lovelace-slider-entity-row";
  version = "17.5.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-slider-entity-row";
    rev = version;
    hash = "sha256-/unrsfM2s9vZUIQOoMEOr1n01KBgidpGRZ+NDjNNweY=";
  };
  npmDepsHash = "sha256-McydFWHwu0eiyWxq+tpqDsfgz4M4rhLzj9xtAReq40k=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./slider-entity-row.js $out/

    runHook postInstall
  '';


  passthru = {
    entrypoint = "slider-entity-row.js";
  };

  meta = with lib; {
    description = "Add sliders to entity cards";
    homepage = "https://github.com/thomasloven/lovelace-slider-entity-row";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "lovelace-slider-entity-row";
    platforms = platforms.linux;
  };
}
