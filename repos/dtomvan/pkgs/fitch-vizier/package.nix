{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  fetchpatch,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fitch-vizier";
  version = "0-unstable-2026-08-31";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "fundamentalcomputing";
    repo = "fitchvizier";
    rev = "5fafd203e0dadd78ba95147b7fd2ef492ce3a2ea";
    hash = "sha256-BgFvupg69Y+8lGgwWTPFCvcFjqZKBZFKlNk/BrUvAbw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/friedelschoen/FitchVIZIER/commit/81f9edea9aab394292be43d5de14d26f2576c275.patch";
      hash = "sha256-3SRKBQdOeVr1FAZOlqMQ/2GuCI6sgyxLmA2mpKda6I4=";
    })
    ./workspace-toml.patch
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    hash = "sha256-YzpHJWcdkcnsmVH9YvjJaZU1c5T477mYP5oOArOD2Qo=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fitch-style prover";
    homepage = "https://github.com/FundamentalComputing/FitchVIZIER";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "fitchv";
  };
})
