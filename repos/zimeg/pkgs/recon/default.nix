{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "recon";
  version = "0.6.1-unstable-2026-06-24"; # https://github.com/mwbrooks/recon/tree/fix-discover-wrapped-claude

  src = fetchFromGitHub {
    owner = "mwbrooks";
    repo = "recon";
    rev = "5a39fd8367334d410bcef9992988e92e579fbb18";
    hash = "sha256-SOgYB8PSR4uwYY5sWU4gpxUTaKYeJZkBEwRf24GBvNw=";
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
