{
  lib,
  rustPlatform,
  rustc,
  rosec,
  lld,
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "rosec-bitwarden-pm";

  version = "0.1.0";

  inherit (rosec) src;

  sourceRoot = "${src.name}/${pname}";

  cargoHash = "sha256-hNeCZPclwz2WMKnHsECBL0TduqkWsYhadEfsw54lGBg=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.93"' 'rust-version = "${rustc.version}"'
  '';

  env.RUSTFLAGS = "-C linker=wasm-ld";
  nativeBuildInputs = [lld];

  meta = {
    description = "A Bitwarden (Personal) provider for rosec";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    platforms = lib.platforms.wasi;
    maintainers = [];
  };
})
