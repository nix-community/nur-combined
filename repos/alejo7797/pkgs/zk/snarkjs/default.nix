{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "snarkjs";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = "snarkjs";
    rev = "v${version}";
    hash = "sha256-9+sph+mca5ToC8l4l3hDdT0jLLeY7fuQi5lbH/BUHOQ=";
  };

  npmDepsHash = "sha256-UfaB+aExi0kSjqiCFErvwTlK9hdq7kxtDUIzNxPx2Uc=";
  npmPackFlags = [ "--ignore-scripts" ];

  meta = {
    description = "zkSNARK implementation in JavaScript & WASM";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/iden3/snarkjs";
    mainProgram = "snarkjs";
  };
}
