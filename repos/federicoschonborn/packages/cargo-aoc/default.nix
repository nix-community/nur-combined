{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-aoc";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "gobanos";
    repo = pname;
    rev = version;
    sha256 = "sha256-j7fX9zUkFGWKMMWK7rmgK5Tg+5XwFTx17ZFQPCF4xfU=";
  };

  cargoSha256 = "sha256-U2mAhlQv8sZQOLpeWWE7vdjbhVtGnb7GZ3jUIO8LkxQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "Cargo Advent of Code Helper";
    longDescription = ''
      cargo-aoc is a simple CLI tool that aims to be a helper for the Advent of Code.

      Implement your solution. Let us handle the rest.
    '';
    homepage = "https://github.com/gobanos/cargo-aoc";
    license = with licenses; [asl20 mit];
  };
}
