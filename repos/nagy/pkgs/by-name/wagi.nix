{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wagi";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "deislabs";
    repo = "wagi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Hy9IDAuLVD1PI6pPFwKTyoACQUOAuINPWgRoXOrYC7I=";
  };

  cargoHash = "sha256-ohDvF5/jD3ZMhL9qm1QagfSWPEZQL7CKDkXJ+fRE5As=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # tests fail
  doCheck = false;

  meta = {
    homepage = "https://github.com/deislabs/wagi";
    description = "Write HTTP handlers in WebAssembly with a minimal amount of work";
    license = lib.licenses.asl20;
  };
})
