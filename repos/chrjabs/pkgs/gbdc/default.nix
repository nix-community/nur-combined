{
  lib,
  python,
  fetchFromGitHub,
  scikit-build-core,
  pybind11,
  cmake,
  ninja,
  libarchive,
  cadical,
}:
python.pkgs.buildPythonPackage (
  (import ./shared.nix {
    inherit lib;
    inherit fetchFromGitHub;
    inherit libarchive;
    inherit cadical;
  })
  // {
    pyproject = true;
    dontUseCmakeConfigure = true;

    build-system = [
      pybind11
      cmake
      scikit-build-core
      ninja
    ];

    pythonImportsCheck = [ "gbdc" ];
  }
)
