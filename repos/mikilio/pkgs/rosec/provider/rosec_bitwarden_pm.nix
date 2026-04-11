{
  lib,
  fetchFromGitHub,
  rustPlatform,
  rustc,
  lld,
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "rosec_bitwarden_pm";

  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jmylchreest";
    repo = "rosec";
    # tag = "v${version}";
    rev = "d4649c1a41b0a297f1577b376ca46364e059e51f";
    hash = "sha256-fiwh9mV+t1x0mwHXI5aUmBxXzSFRg/k39ho4qzgzLD0=";
  };

  sourceRoot = "${src.name}/rosec-bitwarden-pm";

  cargoHash = "sha256-hNeCZPclwz2WMKnHsECBL0TduqkWsYhadEfsw54lGBg=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.93"' 'rust-version = "${rustc.version}"'
  '';

  env.RUSTFLAGS = "-C linker=wasm-ld";
  nativeBuildInputs = [lld];

  meta = {
    description = "A secrets daemon implementing the freedesktop.org Secret Service API with modular backend providers ";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    broken = true;
    maintainers = [];
  };
})
