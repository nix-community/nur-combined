{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "lovelace-slider-entity-row";
  version = "17.5.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-slider-entity-row";
    rev = "v${version}";
    hash = "sha256-1lfYQRi/uW5gbH50yO3l9FUuUmn5mz5rHTPn/fi8fcE=";
  };
  npmDepsHash = "sha256-RIIg7xRO1gplYcLE0bjcOUT/8gRQpoVfA9vM+CsYbJw=";

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
