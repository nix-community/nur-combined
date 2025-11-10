{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage rec {
  pname = "veripb";
  version = "3.0.1";

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "software/VeriPB";
    rev = version;
    hash = "sha256-YbX2Amcavf1XOILRMaLjpWD1K/QnUyUnrvtRCzncJTw=";
  };

  cargoHash = "sha256-KTXoUV3ho7lEz6txs/TgMEBDKpfOplfrWq0OAomjFfE=";

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
