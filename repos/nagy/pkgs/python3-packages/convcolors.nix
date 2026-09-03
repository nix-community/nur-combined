{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "convcolors";
  version = "2.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QDaEjpiudSq6xKVKy4ebZxH43PL3aIFchTZjWaKHwb0=";
  };

  pythonImportsCheck = [ "convcolors" ];

  build-system = [ setuptools ];

  meta = {
    description = "Python package for converting colors between different color spaces";
    homepage = "https://pypi.org/project/convcolors/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
