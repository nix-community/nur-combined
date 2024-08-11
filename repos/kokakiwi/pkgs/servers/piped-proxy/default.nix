{ lib, stdenv, darwin

, fetchFromGitHub

, rustPlatform

, pkg-config

, openssl
, zstd
}:
rustPlatform.buildRustPackage {
  pname = "piped-proxy";
  version = "0-unstable-2024-08-10";

  src = fetchFromGitHub {
    owner = "TeamPiped";
    repo = "piped-proxy";
    rev = "dce6ee79652343a25795bf6e42cf95b39c945346";
    hash = "sha256-PqX7UjOwfe+aEQ2XxvKi1eAh7dZipfFlpfoDMeE1Wrg=";
  };

  cargoHash = "sha256-6ql6Gi7+jh7a9VC5u8/L8sfa93WRzbw1dLUTebY+9L4=";

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
