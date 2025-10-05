{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "westra-passes";
  version = "0-unstable-2025-01-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "westra_passes_for_nakarte";
    rev = "98912314a192f58679c812b61c3a710891fbea7c";
    hash = "sha256-Mtwmpvq0EK1H+Xz6HWmauKpo+ApSqfsgKOEGR3JwIXs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    shapely
    numpy
    scipy
    odfpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Mountain passes for nakarte";
    homepage = "https://github.com/wladich/westra_passes_for_nakarte";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
