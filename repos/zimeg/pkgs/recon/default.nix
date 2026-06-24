{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "recon";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "mwbrooks";
    repo = "recon";
    rev = "ca5a0e789ab841d3d192e1ef45cd94a997ebee86";
    hash = "sha256-wyIgmSsrblR5eCA6R8aoZlINVMflyaJWFYpLupcyJT4=";
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
