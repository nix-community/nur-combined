{
  lib,
  rustPlatform,
  rustc,
  rosec,
  lld,
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "rosec-bitwarden-sm";

  version = "0.1.0";

  inherit (rosec) src;

  sourceRoot = "${src.name}/${pname}";

  cargoHash = "sha256-E4xxxK+7LEyYh7QtLnN8bHYwb2I9DQ7t4Inxbu72Fq4=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.93"' 'rust-version = "${rustc.version}"'
  '';

  env.RUSTFLAGS = "-C linker=wasm-ld";
  nativeBuildInputs = [lld];

  meta = {
    description = "A Bitwarden Sercet Manager provider for rosec";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    platforms = lib.platforms.wasi;
    maintainers = [];
  };
})
