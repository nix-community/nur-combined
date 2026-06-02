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
  version = "0.0.9-unstable-2026-05-27";

  src = fetchFromGitHub {
    owner = "Cuprate";
    repo = "cuprate";
    rev = "e00df6190472f7140d6866d8f2bf3b00786e2f8b";
    hash = "sha256-SeJka5CwgplmMOAZGldnZq3RcanBxm7Zo5gseeh+koc=";
    leaveDotGit = true;
  };

  cargoHash = "sha256-eHuLB++eRzGYcx7ZC4n2AdlWdqlO6JZDMPdSTVb+lPg=";

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
