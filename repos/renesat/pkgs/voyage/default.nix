{
  fetchFromGitHub,
  rustPlatform,
  lib,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "voyage";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "clickswave";
    repo = "voyage";
    rev = "v${version}";
    hash = "sha256-qiPGJDV3EYSleeLMFCUcE/KXDtQWMevAmjPneLoKa58=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [openssl];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  meta = {
    description = "Voyage is a stateful subdomain enumeration tool that combines passive and active techniques with resumable scans, user-specific databases, and fine-grained control built for efficient, reliable reconnaissance.";
    homepage = "https://github.com/clickswave/voyage";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
