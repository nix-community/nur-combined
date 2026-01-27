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
  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  meta = {
    description = "Provides support for infrared cameras that are not directly enabled out-of-the box on Linux";
    homepage = "https://github.com/EmixamPP/linux-enable-ir-emitter";
    changelog = "https://github.com/EmixamPP/linux-enable-ir-emitter/releases/tag/${version}";
    license = lib.licenses.mit;
    mainProgram = "linux-enable-ir-emitter";
  };
}
