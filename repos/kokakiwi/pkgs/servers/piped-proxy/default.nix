{ lib, stdenv, darwin

, fetchFromGitHub

, rustPlatform

, pkg-config

, openssl
, zstd
}:
rustPlatform.buildRustPackage {
  pname = "piped-proxy";
  version = "unstable-2024-08-08";

  src = fetchFromGitHub {
    owner = "TeamPiped";
    repo = "piped-proxy";
    rev = "c6f6ddb2d0f947700cd025420e7411031f34247e";
    hash = "sha256-TV8zDlY1Rw5dABMnU7votqKtfv4zdkoSCuXguYhIoxY=";
  };

  cargoHash = "sha256-i0UKaZ/fTmcZaj8IQDdX3KaqmOwy8+i5SQ1K0bDxjFE=";

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
