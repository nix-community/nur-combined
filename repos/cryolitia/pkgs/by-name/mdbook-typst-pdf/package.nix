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
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "KaiserY";
    repo = "mdbook-typst-pdf";
    rev = "v${version}";
    hash = "sha256-SJWQAk8m2ssEVMV3T8ofLXHZTgShuCgAzKNaAapw6hs=";
  };

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  OPENSSL_NO_VENDOR = 1;

  cargoHash = "sha256-ep5GKfbwmjJ9esoL2scdOWNLddKi7ig2E/JqWhyLTXQ=";

  meta = with lib; {
    description = "将 mdBook 转换为 PDF。";
    homepage = "https://github.com/KaiserY/mdbook-typst-pdf";
    license = licenses.asl20;
    maintainers = with maintainers; [ Cryolitia ];
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
