{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  openssl,
  pkg-config,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "mdbook-typst-pdf";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "KaiserY";
    repo = "mdbook-typst-pdf";
    rev = "v${version}";
    hash = "sha256-UEwV58e5/ctfC5A+lVy16VWdl/v5yJWy59e1/B9gkyg=";
  };

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        Security
        SystemConfiguration
      ]
    );

  nativeBuildInputs = [
    pkg-config
  ];

  OPENSSL_NO_VENDOR = 1;

  cargoHash = "sha256-JWJ+vzuSgbBlixTWbQpIefowk1daws45VrjJCwP3MFE=";

  meta = with lib; {
    description = "将 mdBook 转换为 PDF。";
    homepage = "https://github.com/KaiserY/mdbook-typst-pdf";
    license = licenses.asl20;
    maintainers = with maintainers; [ Cryolitia ];
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
