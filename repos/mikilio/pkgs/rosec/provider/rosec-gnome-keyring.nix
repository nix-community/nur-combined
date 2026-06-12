{
  lib,
  rustPlatform,
  rustc,
  rosec,
  lld,
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "rosec-gnome-keyring";

  version = "0.1.0";

  inherit (rosec) src;

  sourceRoot = "${src.name}/${pname}";

  cargoHash = "sha256-gkbD1N4veXhETwc5uzL/eq7a6naGq6suqJOAp53suFI=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.93"' 'rust-version = "${rustc.version}"'
  '';

  env.RUSTFLAGS = "-C linker=wasm-ld";
  nativeBuildInputs = [lld];

  meta = {
    description = "A GNOME keyring provider for rosec";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    platforms = lib.platforms.wasi;
    maintainers = [];
  };
})
