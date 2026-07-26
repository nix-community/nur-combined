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

  # Work around nixpkgs rust 1.95 / LLVM 21.1.8 toolchain mismatch: rustc's
  # stdarch declares the old llvm.x86.avx512.vpdpbusd.512 signature, so
  # compiling rten-gemm's avx512vnni int8 dot path fails. This package never
  # enables avx512vnni at compile time, so disable that path in the vendored
  # rten-gemm crate and fall back to the avx2 path.
  preBuild = ''
    d=$(find "$NIX_BUILD_TOP" -type d -name 'rten-gemm-0.24.0' 2>/dev/null | head -n1)
    [ -n "$d" ] && patch -p1 -d "$d" < ${./rten-gemm-avx512vnni.patch}
  '';

  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight multilingual translation service powered by the pure Rust LinguaSpark inference engine, compatible with multiple translation frontend APIs";
    homepage = "https://github.com/LinguaSpark/server";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
