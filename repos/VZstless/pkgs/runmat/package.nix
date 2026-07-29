{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
  hdf5,
  cmake,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bc17TPg69vQeCa1m9Ni6P1Md5/v1oq2k2Oh59mf+ElE=";
  };

  cargoHash = "sha256-Fg91vcZyVuk5hVGRnLs+KqJtIqagEeHDJ9P9svqRrjE=";

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

  meta = {
    description = "Open-source runtime for math. MATLAB syntax";
    homepage = "https://runmat.com/";
    license = lib.licenses.mit;
    mainProgram = "runmat";
  };
})
