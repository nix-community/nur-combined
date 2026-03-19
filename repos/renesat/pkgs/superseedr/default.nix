{
  fetchFromGitHub,
  rustPlatform,
  lib,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "superseedr";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "Jagalite";
    repo = "superseedr";
    rev = "v${version}";
    hash = "sha256-C2U3claHvSkRHxc7dAMEI0cosJnjMAsuBlFy3cNJuBA=";
  };

  cargoHash = "sha256-5jtkYW++OdF7mKHl6Yw/xshbt/oEVvG3PFa+xnDqE9k=";

  nativeBuildInputs = [openssl];

  # Needed to get openssl-sys.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  meta = {
    description = "A Rust BitTorrent Client in your Terminal";
    homepage = "https://github.com/Jagalite/superseedr";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
