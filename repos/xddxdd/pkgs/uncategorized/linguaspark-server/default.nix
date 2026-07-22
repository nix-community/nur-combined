{
  sources,
  lib,
  rustPlatform,
  buildArch ? null,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.linguaspark-server) pname version src;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-zmyBVEldNwNZvScs0PBRZtXXSk7vx6v/vC08bZl7bg0=";
  };

  env.RUSTFLAGS = lib.optionalString (buildArch != null) "-C target-cpu=${buildArch}";

  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight multilingual translation service powered by the pure Rust LinguaSpark inference engine, compatible with multiple translation frontend APIs";
    homepage = "https://github.com/LinguaSpark/server";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
