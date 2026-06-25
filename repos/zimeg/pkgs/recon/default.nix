{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "recon";
  version = "0.6.1-unstable-2026-06-25"; # https://github.com/zimeg/recon/tree/feat/detect-claude-wrapped

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "recon";
    rev = "e92e62aa3ad5f7901342cbdd87e429bb59e9fa4d";
    hash = "sha256-SRkwhH7FI8fBn16i5tZiLrM7xHw/53HfTQMU6rm+mGQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "tmux-native dashboard for managing Claude Code agents";
    homepage = "https://github.com/mwbrooks/recon";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "recon";
  };
}
