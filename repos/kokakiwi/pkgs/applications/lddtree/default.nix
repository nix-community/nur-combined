{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lddtree";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "lddtree-rs";
    rev = "v${version}";
    hash = "sha256-hrWdCLbehiC6XNmm8ai5A0KrZJzpSTnJVKNqBTBFxzw=";
  };

  cargoHash = "sha256-hLNFicQL43nhBYkj1iE1+6rJBWi3/GDlmzy6JqItZB8=";

  meta = with lib; {
    description = "Read the ELF dependency tree";
    homepage = "https://github.com/messense/lddtree-rs";
    license = licenses.mit;
    mainProgram = "lddtree";
  };
}
