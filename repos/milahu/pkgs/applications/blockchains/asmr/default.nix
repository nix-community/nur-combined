{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "asmr";
  version = "unstable-2021-12-11";

  src =
  #if true then /home/user/src/asmr else
  if true then
  fetchFromGitHub {
    owner = "milahu";
    repo = "asmr";
    rev = "ace12a39e3593e26a669cb1376922ea3761d9419";
    hash = "sha256-y1eKtin80debo7sNbnE0a5YIz75Ck0W6M9fKHcBiOGA=";
  }
  else
  fetchFromGitHub {
    owner = "MerosCrypto";
    repo = "asmr";
    rev = "f7623dda07d052835acb35ff11338e1d98d93f97";
    hash = "sha256-cfOuKo5tazQm24HgVSftCuYSdUfPVUSNIV1nkKfabLE=";
  };

  cargoHash = "sha256-/P/sQ5VHELB6Ft5d6OYzjW344bnyJAl2u1XGNZGRYAs=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Atomic Swaps for cryptocurrencies: Bitcoin Meros Nano Monero";
    homepage = "https://github.com/MerosCrypto/asmr";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "asmr";
  };
}
