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
    tag = "cuprated-${finalAttrs.version}";
    hash = "sha256-MEvbeuWDjvKvrU1FRs3mGp+OXMxuzN3UcLOmFnJz9q4=";
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
