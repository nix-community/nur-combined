{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, udev
, openssl
}:

rustPlatform.buildRustPackage {
  pname = "spl-token-cli";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "solana-program";
    repo = "token-2022";
    rev = "714a2ce6d2b5ed5f6df05b2dd3c92b2a2aa4e0be";
    hash = "sha256-fn0kRKCnSOmdzVEluDit+iofMVeBv22wO17uYNdw85M=";
  };

  cargoHash = "sha256-vD45hWLIvcsZ2c1mcqHh+7AM9pigCg8DjAFpvcbyS4c=";

  cargoBuildFlags = [ "-p spl-token-cli" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev openssl ];
  strictDeps = true;

  doCheck = false;

  meta = with lib; {
    description = "A basic command-line for creating and using SPL Tokens";
    homepage = "https://github.com/solana-program/token-2022";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "spl-token";
    broken = false;
  };
}
