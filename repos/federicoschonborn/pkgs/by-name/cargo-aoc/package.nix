{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  versionCheckHook,
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
    rev = "refs/tags/${version}";
    hash = "sha256-k9Lm91+Bk6EC8+KfEXhSs4ki385prZ6Vbs6W+18aZSI=";
  };

  cargoHash = "sha256-DKP9YMbVojK7w5pkX/gok4PG6WUjhqUdvTwSir05d0s=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "cargo-aoc";
    description = "Cargo Advent of Code Helper";
    homepage = "https://github.com/gobanos/cargo-aoc";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
