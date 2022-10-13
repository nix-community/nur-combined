{ lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "wagi";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "deislabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Hy9IDAuLVD1PI6pPFwKTyoACQUOAuINPWgRoXOrYC7I=";
  };

  cargoSha256 = "sha256-ohDvF5/jD3ZMhL9qm1QagfSWPEZQL7CKDkXJ+fRE5As=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # tests fail
  doCheck = false;

  meta = with lib; {
    inherit (src.meta) homepage;
    description =
      "Write HTTP handlers in WebAssembly with a minimal amount of work";
    license = licenses.asl20;
  };
}
