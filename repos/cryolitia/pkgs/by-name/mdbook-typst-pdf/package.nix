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
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "KaiserY";
    repo = "mdbook-typst-pdf";
    rev = "v${version}";
    hash = "sha256-RwIlIZYAPO0FN6wMq6gO2Oq2vR2lp6IpGlh8WyY0Pbs=";
  };

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  OPENSSL_NO_VENDOR = 1;

  cargoHash = "sha256-bQ+zZpmVUs9dFPq6fnjoOZWAdvIlqHlS97//pHYs2Yg=";

  meta = with lib; {
    description = "将 mdBook 转换为 PDF。";
    homepage = "https://github.com/KaiserY/mdbook-typst-pdf";
    license = licenses.asl20;
    maintainers = with maintainers; [ Cryolitia ];
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
