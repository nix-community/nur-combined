{
  sources,
  version,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  inherit version;
  cargoLock = sources.cargoLock."Cargo.lock";
  meta = {
    description = "Jq clone focused on correctness, speed and simplicity";
    homepage = "https://github.com/01mf02/jaq";
    changelog = "https://github.com/01mf02/jaq/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "jaq";
  };
}
