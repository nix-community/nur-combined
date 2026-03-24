{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "mdbook-typst-pdf";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "KaiserY";
    repo = "mdbook-typst-pdf";
    rev = "v${version}";
    hash = "sha256-ASM8U6tFViRoMfc1DhTVSLr7P9eksGP3suD/+UOkPcE=";
  };

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  OPENSSL_NO_VENDOR = 1;

  cargoHash = "sha256-ZcVjAvQrplLW42e6t9e/QsmTPBmhQfIFR7SnemuqEgI=0.7.2";

  meta = with lib; {
    description = "将 mdBook 转换为 PDF。";
    homepage = "https://github.com/KaiserY/mdbook-typst-pdf";
    license = licenses.asl20;
    maintainers = with maintainers; [ Cryolitia ];
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
