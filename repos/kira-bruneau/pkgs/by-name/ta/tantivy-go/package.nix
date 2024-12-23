{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "tantivy-go";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    tag = "v${version}";
    hash = "sha256-IlGtyTjOAvmrbgmvy4NelTOgOWopxNta3INq2QcMEqY=";
  };

  sourceRoot = "${src.name}/rust";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
    chmod +w ../bindings.h
  '';

  meta = with lib; {
    description = "Tantivy go bindings";
    homepage = "https://github.com/anyproto/tantivy-go";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
