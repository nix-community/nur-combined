{ lib
, buildPythonPackage
, fetchFromGitHub
, pybind11
, setuptools
, wheel
, numpy
, psutil
}:

buildPythonPackage rec {
  pname = "pyspng";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nurpax";
    repo = "pyspng";
    rev = "v${version}";
    hash = "sha256-Li1uKDLcM7Sxl0n4w87MfEpw+Qiyw7MILhytwFNUoDk=";
  };

  nativeBuildInputs = [
    pybind11
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    numpy
    psutil
  ];

  pythonImportsCheck = [ "pyspng" ];

  meta = with lib; {
    description = "Python bindings for libspng.  Use with numpy";
    homepage = "https://github.com/nurpax/pyspng";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
  };
}
