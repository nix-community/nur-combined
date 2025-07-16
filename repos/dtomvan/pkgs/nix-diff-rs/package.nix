{
  lib,
  rustPlatform,
  fetchFromGitHub,
  rust-jemalloc-sys,
}:

rustPlatform.buildRustPackage {
  pname = "nix-diff-rs";
  version = "0-unstable-2025-07-16";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-diff-rs";
    rev = "bd5d3d2ba4470b3b4a9acddcd0d5ba9968235416";
    hash = "sha256-wW5rtQQkGdtGBqtwXVIn4dUKz7Y8bV82bZTt0EstlWE=";
  };

  cargoHash = "sha256-Cq8YHUR1qPiFg6k0O8w796wrZKhI4w611sWF59F4jQY=";

  buildInputs = [
    rust-jemalloc-sys
  ];

  # integration tests seem to fail as of yet, might have to do with the sandbox
  doCheck = false;

  meta = {
    description = "A Rust port of nix-diff, a tool to explain why two Nix derivations differ";
    homepage = "https://github.com/Mic92/nix-diff-rs";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "nix-diff";
  };
}
