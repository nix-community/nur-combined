{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage rec {
  pname = "veripb";
  version = "3.0.0";

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "software/VeriPB";
    rev = version;
    hash = "sha256-FLgCMK16XQ0Q5xUmc5vOCV9HvjkIOcK5rNu9RTws2wU=";
  };

  cargoHash = "sha256-LhPtR8Re4+m+rMYs/A9Hc3/S0sDJDGtRn7BWbGfKruk=";

  meta = {
    description = "VeriPB is a proof checker for verifying pseudo-Boolean certificates of satisfiability, unsatisfiability, and optimality bounds";
    homepage = "https://gitlab.com/MIAOresearch/software/VeriPB";
    changelog = "https://gitlab.com/MIAOresearch/software/VeriPB/-/blob/${src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "veripb";
  };
}
