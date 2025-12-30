{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lddtree";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "lddtree-rs";
    rev = "v${version}";
    hash = "sha256-7v/pftRvTIwOs2dINL5JjFM7EKg8QhtUcgcPQ4DRTFY=";
  };

  cargoHash = "sha256-OvQ8ZEgCKcamMErnJ6CkA+V0saGSLwJcl5gDPjBr3To=";

  meta = with lib; {
    description = "Read the ELF dependency tree";
    homepage = "https://github.com/messense/lddtree-rs";
    license = licenses.mit;
    mainProgram = "lddtree";
  };
}
