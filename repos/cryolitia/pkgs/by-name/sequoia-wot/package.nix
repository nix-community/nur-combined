{
  lib,
  rustPlatform,
  fetchFromGitLab,
  libclang,
  pkg-config,
  nettle,
  openssl,
  sqlite,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "sequoia-wot";
  version = "0.11.0";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "sequoia-wot";
    rev = "v${version}";
    hash = "sha256-qSf2uESsMGUEvAiRefpwxHKyizbq5Sst3SpjKaMIWTQ=";
  };

  cargoPatches = [
    ./01-cargo-lock.patch
    ./02-cargo-toml.patch
  ];

  cargoHash = "sha256-ZPVvRulCXG81eTuL2oettUrrFWEmZk8VzD9YB+P+wVc=";

  nativeBuildInputs = [
    pkg-config
    libclang
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libclang
    nettle
    openssl
    sqlite
  ];

  buildFeatures = [ "sequoia-openpgp/default" ];

  # Panic caused by accessing GNUPGHOME in https://gitlab.com/sequoia-pgp/sequoia-wot/-/blob/v0.11.0/tests/gpg.rs?ref_type=tags#L25
  doCheck = false;

  meta = with lib; {
    description = "A Rust CLI tool for authenticating bindings and exploring a web of trust";
    homepage = "https://gitlab.com/sequoia-pgp/sequoia-wot";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "sq-wot";
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
