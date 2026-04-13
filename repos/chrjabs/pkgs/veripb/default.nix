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
    rev = "4f3361cc34473ae782b08920e0512a4067b9603a";
    # tag = version;
    hash = "sha256-tG9wztQeb6erDVixnogkbPc3u47skBno+RF9/rmQa48=";
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
