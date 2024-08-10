{ lib, fetchPypi, buildPythonPackage, setuptools-scm }:

buildPythonPackage rec {
  pname = "convcolors";
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QDaEjpiudSq6xKVKy4ebZxH43PL3aIFchTZjWaKHwb0=";
  };

  pythonImportsCheck = [ "convcolors" ];

  nativeBuildInputs = [ setuptools-scm ];

  meta = with lib; {
    description =
      "Python package for converting colors between different color spaces";
    homepage = "https://pypi.org/project/convcolors/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
