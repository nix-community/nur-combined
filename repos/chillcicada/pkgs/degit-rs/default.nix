{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "degit-rs";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "psnszsn";
    repo = pname;
    rev = "c7dbeb75131510a79400838e081b90665c654c80";
    hash = "sha256-swyfKnYQ+I4elnDnJ0yPDUryiFXEVnrGt9xHWiEe6wo=";
  };

  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./add-Cargo.lock.patch
  ];

  sourceRoot = src.name;

  cargoHash = "sha256-bUoZsXU7iWK7MZ/hXk1JNUX1hN88lrU1mc1rrYuiCYs=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # skip test cases
  doCheck = false;

  meta = with lib; {
    description = "Rust rewrite of degit";
    homepage = "https://github.com/psnszsn/degit-rs";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "degit";
  };
}
