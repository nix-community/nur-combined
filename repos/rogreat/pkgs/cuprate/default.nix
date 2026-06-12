{
  cmake,
  fetchFromGitHub,
  lib,
  monero-cli,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cuprate";
  version = "cuprated-0.0.9";

  src = fetchFromGitHub {
    owner = "Cuprate";
    repo = "cuprate";
    rev = "bc059f047651a743565330e8fe533e4f5a81d388";
    hash = "sha256-IQcyLtQtc8xNGFt7V1Y1qBW5Zr941jZy7jdHOxiDvqo=";
  };

  cargoHash = "sha256-NDZb/DLNP35EKqsoLz/AallYyeHcm9M+DtNxZzq+PFQ=";

  checkFlags = [
    # Tests don't work in CI
    "--skip rpc::client::tests::localhost"
    "--skip rpc::client::tests::get"
    "--skip data::statics::tests::block_same_as_rpc"
    "--skip data::statics::tests::tx_same_as_rpc"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  preCheck = ''
    ln -s ${monero-cli}/bin/monerod monerod
  '';

  env = {
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    # Use Rust nightly.
    RUSTC_BOOTSTRAP = 1;
    # https://github.com/Cuprate/cuprate/blob/main/constants/build.rs
    GITHUB_SHA = finalAttrs.src.rev;
  };

  meta = {
    description = "Modular Monero node written in Rust";
    homepage = "https://cuprate.org";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cuprated";
    platforms = lib.platforms.linux;
  };
})
