{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
  hdf5,
  cmake,
  perl,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j4YXQwPvnSRzYvJEMROLrN2nIYcl1A0eC0nwpeAHbrE=";
  };

  cargoHash = "sha256-mM5lmYbpbatvaUNciKRNxkuF1xcZpBk/YIIayUnk7O8=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    openblas
    openssl
    hdf5
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source runtime for math. MATLAB syntax";
    homepage = "https://runmat.com/";
    license = lib.licenses.mit;
    mainProgram = "runmat";
  };
})
