{
  stdenv,
  nix-update-script,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "nob.h";
  version = "0-unstable-2025-08-21";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "nob.h";
    rev = "8ddbc72d7ece4ac638c3df0ddf636e54b35e099f";
    hash = "sha256-hwyg1fJxGcRafF7bISkAdLYeetaee6Y9pXArsMtDSqI=";
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
