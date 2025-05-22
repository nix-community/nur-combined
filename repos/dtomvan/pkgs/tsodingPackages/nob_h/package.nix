{
  stdenv,
  nix-update-script,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "nob.h";
  version = "0-unstable-2025-04-24";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "nob.h";
    rev = "112911eba033af91e3d6e7100f8dde69127b3525";
    hash = "sha256-FW3X15MeaoJ2wBm20Dup1GhBW1+eNbJ3ynF5kBLLKcM=";
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
