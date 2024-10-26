{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "tantivy-go";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "tantivy-go";
    rev = "refs/tags/v${version}";
    hash = "sha256-RA4bsYZCFlCIpVxSaz32b4aGmZl2/cDBCJAIQ7tyEck=";
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
