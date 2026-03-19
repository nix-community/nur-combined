{
  lib,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "dedoc";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "toiletbril";
    repo = "dedoc";
    rev = version;
    hash = "sha256-B/lZ1G/C/VnSO8Rk67Lhf+hgh97nVooLAu6TxxT0VGs=";
  };

  cargoHash = "sha256-gW7DXJVAxZTTlUD/7+UL0Hk1xeL+HDByfgnoVQRZaOI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "Terminal based viewer for DevDocs";
    homepage = "https://github.com/toiletbril/dedoc";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
