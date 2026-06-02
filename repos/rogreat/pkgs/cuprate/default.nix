{
  cmake,
  fetchFromGitHub,
  git,
  lib,
  monero-cli,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cuprate";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "Cuprate";
    repo = "cuprate";
    rev = "bc059f047651a743565330e8fe533e4f5a81d388";
    hash = "sha256-j8La9+eSC1EPz+Vl+aY+z4HmS6vTyGQjnk9Rj1Md59E=";
    leaveDotGit = true;
  };

  cargoHash = "sha256-NDZb/DLNP35EKqsoLz/AallYyeHcm9M+DtNxZzq+PFQ=";

  nativeBuildInputs = [
    cmake
    git
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
