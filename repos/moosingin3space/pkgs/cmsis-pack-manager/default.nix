{
  lib
, buildPythonPackage
, fetchPypi
, rustPlatform
, setuptools
, setuptools-scm
, setuptools-scm-git-archive
, pyyaml
, appdirs
, milksnake
}:
buildPythonPackage rec {
  version = "0.4.0";
  pname = "cmsis-pack-manager";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-NeUG6PFI2eTwq5SNtAB6ZMA1M3z1JmMND29V9/O5sgw=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  cargoRoot = "rust";

  postPatch = ''
    cp ${./Cargo.lock} ${cargoRoot}/Cargo.lock
  '';

  buildInputs = [
    setuptools
    setuptools-scm
    setuptools-scm-git-archive
  ];

  nativeBuildInputs = [
    setuptools
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
  ]);

  propagatedBuildInputs = [
    appdirs
    pyyaml
    milksnake
  ];
}