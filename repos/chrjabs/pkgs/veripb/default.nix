{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage rec {
  pname = "veripb";
  version = "3.0.2-unstable";

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "software/VeriPB";
    rev = "e4ffda3b7b68bf0ffb42bc14f4170836ba4656e2";
    # tag = version;
    hash = "sha256-7TfKdH+Whk5Tn3nTNqvGSw22RkJlunhUfFvuI51X7FU=";
  };

  cargoHash = "sha256-VlWDsVn0c3AWixazinF+8wAJgLPoceRzeYu0mzqlH9Y=";

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
