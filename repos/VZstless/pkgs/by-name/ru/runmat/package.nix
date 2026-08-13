{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
  hdf5,
  cmake,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8oKRWjLaMotTUr6uERsoGj3WF8e3dKTsN1sQkCRQLmo=";
  };

  cargoHash = "sha256-IuMEYnAqdz6h65OnVaeprqaqqI83OIQgCgzvsTE/N80=";

  nativeBuildInputs = [
    pkg-config
    cmake
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
