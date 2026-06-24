{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "recon";
  version = "0.6.1-unstable-2026-06-24"; # https://github.com/zimeg/recon/tree/feat/detect-claude-wrapped

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "recon";
    rev = "f332e4ab350ca5371d0ae2703f9cb6b37f72d5aa";
    hash = "sha256-r21Wzh14lE/W5ezQoy7zKcoAX+M7tch7+6sOxNVlIZs=";
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
