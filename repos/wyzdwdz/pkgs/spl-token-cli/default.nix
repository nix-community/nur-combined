{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, udev
}:

rustPlatform.buildRustPackage {
  pname = "spl-token-cli";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana-program-library";
    rev = "token-cli-v5.0.0";
    hash = "sha1-544C0IqNvWRZqG5lmlvQPtiI7gU=";
  };

  cargoHash = "sha256-k0fyf8qMSzQvooSspJT1EoPNzhnKDGl7zaSxTJUCZDc=";

  cargoBuildFlags = [ "-p spl-token-cli" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
  strictDeps = true;

  doCheck = false;

  meta = with lib; {
    description = "A Token program on the Solana blockchain";
    homepage = "https://github.com/solana-labs/solana-program-library";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "spl-token";
    broken = false;
  };
}
