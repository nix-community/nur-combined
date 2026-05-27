{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "claw";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ultraworkers";
    repo = "claw-code";
    rev = "main";
    hash = "sha256-4cc14TtAhbXWsI/F9Drem2bErWMuOtG5JgD8H5m12DA=";
  };

  cargoHash = "sha256-bmMscPgzy33nEEmv0KpOKa6bwsoxfi2lscQiyz65zM8=";

  sourceRoot = "source/rust";

  cargoBuildFlags = [ "-p" "rusty-claude-cli" ];

  doCheck = false;

  meta = with lib; {
    description = "Rust implementation of the claw CLI agent harness for Claude";
    homepage = "https://github.com/ultraworkers/claw-code";
    license = licenses.mit;
    mainProgram = "claw";
  };
}
