{
  lib,
  stdenv,
  fetchFromGitHub,
  nix,
}:

stdenv.mkDerivation rec {
  pname = "nix-hell";
  version = "unstable-2024-01-09";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "nix-hell";
    rev = "c683c2dc4f2e7233e48b596d2f9890cb446a9ddd";
    hash = "sha256-5S7fdBWRj0MvMQQnyUpFloyHqbgqik2wJd/Q1EWEdZE=";
  };

  buildPhase = ''
    substituteInPlace nix-hell \
      --replace \
        'exec nix-shell' \
        'exec ${nix}/bin/nix-shell'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nix-hell $out/bin
  '';

  meta = {
    description = "A wrapper for nix-shell";
    homepage = "https://github.com/milahu/nix-hell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nix-hell";
    platforms = lib.platforms.all;
  };
}
