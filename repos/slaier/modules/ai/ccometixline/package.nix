{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "ccometixline";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Haleclipse";
    repo = "CCometixLine";
    rev = "v${version}";
    hash = "sha256-W6+eGp8S6weOlS5WpmMR9JT4BVtyhettmtaFTStmyQk=";
  };

  cargoHash = "sha256-ejSDR43RUebxuHiRG3MsppDhgDpH44o+L+jfOZf0x5A=";

  meta = with lib; {
    description = "High-performance Claude Code statusline tool written in Rust with Git integration";
    homepage = "https://github.com/Haleclipse/CCometixLine";
    license = licenses.mit;
    mainProgram = "ccometixline";
  };
}
