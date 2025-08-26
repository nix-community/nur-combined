{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage {
  __structuredAttrs = true;

  pname = "histutils";
  version = "0.1.0-unstable-2025-08-19";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "histutils";
    rev = "e68440fd5f90274ba626439dc4dc4fe1613949dc";
    hash = "sha256-MY7rnX4SMMHCrbAkQt/YEfR3La3j8vg/fagZbHvuoGE=";
  };

  cargoHash = "sha256-qefQqJmgufN+ituYISGh3W7aZd17xhhZDx/jl2X+v2U=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Import, export or merge zsh or fish history files.";
    mainProgram = "histutils";
    homepage = "https://github.com/josh/histutils";
    license = lib.licenses.mit;
  };
}
