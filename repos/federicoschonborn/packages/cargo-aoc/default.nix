{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, darwin
, openssl
, pkg-config
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-aoc";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "gobanos";
    repo = "cargo-aoc";
    rev = version;
    hash = "sha256-jKQRgO7vEkZgBdnaOHOXJdIN+UB0B1tbo7NxGjq48qQ=";
  };

  cargoHash = "sha256-d64WeMkGr+eW4bb+Xin4qe8fz+MlIJ2yigX9KwZMOJk=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "cargo-aoc";
    description = "Cargo Advent of Code Helper";
    longDescription = ''
      cargo-aoc is a simple CLI tool that aims to be a helper for the Advent of Code.

      Implement your solution. Let us handle the rest.
    '';
    homepage = "https://github.com/gobanos/cargo-aoc";
    license = with lib.licenses; [ asl20 mit ];
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
