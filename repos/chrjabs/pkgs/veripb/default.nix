{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage rec {
  pname = "veripb";
  version = "3.0.2";

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "software/VeriPB";
    tag = version;
    hash = "sha256-7cUxC4JBuNpJ/cEYyX2QE15i1z8lv7VjCALOvIgrrgc=";
  };

  cargoHash = "sha256-TDLssYJxL7M80nQmR7HTtOA4AZDeD7qr9aQ37ZDbgAE=";

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
