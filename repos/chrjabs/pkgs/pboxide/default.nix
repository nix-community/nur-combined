{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage rec {
  pname = "pboxide";
  version = "0.2.0";

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "software/PBOxide";
    rev = version;
    hash = "sha256-yOl7lzEsYSHhjjQ20rql1jZfHKn5GdkCsKXzUR9kzeI=";
  };

  cargoHash = "sha256-9QsL9zwvzrjOkMz7l0pRR+NShfAC/fX2JXltDhMP2rE=";

  meta = {
    description = "Rewrite of the pseudo-Boolean proof checker VeriPB in Rust.";
    homepage = "https://gitlab.com/MIAOresearch/software/PBOxide";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "pboxide_veripb";
  };
}
