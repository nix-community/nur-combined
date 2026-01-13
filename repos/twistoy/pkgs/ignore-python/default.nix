{
  lib,
  python3,
  rustPlatform,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "ignore-python";
  version = "0.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "borsattoz";
    repo = "ignore-python";
    rev = "v${version}";
    hash = "sha256-wa3VzrBRIhc8hduL/3wOCIxtlAaFls/BftFQb2Oxjj4=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoRoot = ".";

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  pythonImportsCheck = [ "ignore" ];

  meta = {
    description = "Rust ignore crate Python bindings";
    homepage = "https://github.com/borsattoz/ignore-python";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
