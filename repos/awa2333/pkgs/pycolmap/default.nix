{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  numpy,
  pybind11,
  pybind11-stubgen,
  scikit-build-core,
  nix-update-script,
  cmake,
  colmap,
  boost,
  eigen,
  openimageio,
  sqlite,
  glew,
  suitesparse,
  ceres-solver,
  cgal,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycolmap";
  version = "4.1.1";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "colmap";
    repo = "colmap";
    tag = finalAttrs.version;
    hash = "sha256-n0crr452nmo3wWnF2FXuhdsFVzAwGeRjq9mlC6ml1eg=";
  };

  patches = [
    ./pyproject-toml.patch
  ];

  cmakeDir = "../python";

  build-system = [
    numpy
    pybind11
    pybind11-stubgen
    scikit-build-core
  ];

  nativeBuildInputs = [
    colmap
    cmake
  ];

  buildInputs = [
    cgal
    ceres-solver
    glew
    sqlite
    openimageio
    eigen
    boost
    suitesparse
  ];

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [
    "pycolmap"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "COLMAP - Structure-from-Motion and Multi-View Stereo";
    homepage = "https://github.com/colmap/colmap";
    changelog = "https://github.com/colmap/colmap/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
  };
})
