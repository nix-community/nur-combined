{
  stdenv,
  nix-update-script,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "nob.h";
  version = "3.8.2-unstable-2026-04-01";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "nob.h";
    rev = "0a08926d8094fc4ae678155c5d73ae21d1f96f3f";
    hash = "sha256-EIINLsuHpNCUO8mQs2TJB2Bcm3imUCzV5FLkg2C83fw=";
  };

  doBuild = false;
  doCheck = true;

  checkPhase = ''
    cc -o nob nob.c
    ./nob
  '';

  installPhase = ''
    install -Dm644 nob.h $out/include/nob.h
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Header only library for writing build recipes in C.";
    homepage = "https://github.com/tsoding/nob.h";
    license = with lib.licenses; [
      mit
      unlicense
    ];
  };
}
