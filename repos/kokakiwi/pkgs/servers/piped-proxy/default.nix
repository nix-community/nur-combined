{ lib, stdenv, darwin

, fetchFromGitHub

, rustPlatform

, pkg-config

, openssl
, zstd
}:
rustPlatform.buildRustPackage {
  pname = "piped-proxy";
  version = "0-unstable-2024-08-19";

  src = fetchFromGitHub {
    owner = "TeamPiped";
    repo = "piped-proxy";
    rev = "79f27fbfc97fd99abc14772cab56c243be464407";
    hash = "sha256-91pIfpZ4Ty2saucms8cJ/QeWD36kvoBTe/FqCqGw2IU=";
  };

  cargoHash = "sha256-H0wq3y4ZxFbBqUt7RvJQYcdUVxE8JscepisYoRywz9k=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    zstd
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    Security
  ]);

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = with lib; {
    description = "A proxy for Piped written in Rust";
    homepage = "https://github.com/TeamPiped/piped-proxy";
    license = licenses.agpl3Only;
    mainProgram = "piped-proxy";
  };
}
