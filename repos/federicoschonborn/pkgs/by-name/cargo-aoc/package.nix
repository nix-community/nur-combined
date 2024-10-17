{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  testers,
  cargo-aoc,
  nix-update-script,
}:

let
  version = "0.3.7";
in

rustPlatform.buildRustPackage {
  pname = "cargo-aoc";
  inherit version;

  src = fetchFromGitHub {
    owner = "gobanos";
    repo = "cargo-aoc";
    rev = version;
    hash = "sha256-k9Lm91+Bk6EC8+KfEXhSs4ki385prZ6Vbs6W+18aZSI=";
  };

  cargoHash = "sha256-DKP9YMbVojK7w5pkX/gok4PG6WUjhqUdvTwSir05d0s=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  passthru = {
    tests.version = testers.testVersion {
      package = cargo-aoc;
      # https://github.com/gobanos/cargo-aoc/blob/ab4e29f0ade2dffa1fc861234c45ff8a23cd1f7c/cargo-aoc/src/main.rs#L17
      version = "0.3.0";
    };

    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "cargo-aoc";
    description = "Cargo Advent of Code Helper";
    homepage = "https://github.com/gobanos/cargo-aoc";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
