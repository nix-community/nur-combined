{
  sources,
  version,
  lib,
  rustPlatform,
  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  inherit version;
  cargoLock = sources.cargoLock."Cargo.lock";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];
  cargoBuildFlags = [
    "-p"
    "fast-nix-gc"
    "-p"
    "fast-nix-optimise"
  ];
  cargoTestFlags = [
    "-p"
    "fast-nix-gc"
    "-p"
    "fast-nix-common"
    "-p"
    "fast-nix-optimise"
  ];
  meta = {
    description = "Faster nix-collect-garbage";
    homepage = "https://github.com/Mic92/fast-nix-gc";
    license = lib.licenses.mit;
    mainProgram = "fast-nix-gc";
  };
}
