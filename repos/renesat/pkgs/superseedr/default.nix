{
  fetchFromGitHub,
  rustPlatform,
  lib,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "superseedr";
  version = "0.9.32";

  src = fetchFromGitHub {
    owner = "Jagalite";
    repo = "superseedr";
    rev = "v${version}";
    hash = "sha256-+d+S4+gnucxbkuwnfHdPuPtTPc/XwuCXLWB4GEuGDmg=";
  };

  cargoHash = "sha256-HbTil4HpnclZkE+lJ+B1Wx2O7Cr0VpnBfAHRKtt4E7Y=";

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
