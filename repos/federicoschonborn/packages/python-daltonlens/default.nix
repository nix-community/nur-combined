{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "daltonlens";
  version = "0.1.5";

  format = "pyproject";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  propagatedBuildInputs = [
    python3Packages.numpy
    python3Packages.pillow
  ];

  pythonImportsCheck = [
    "daltonlens"
  ];

  meta = with lib; {
    description = "Utility to help colorblind people by providing color filters and highlighting tools";
    homepage = "https://pypi.org/project/daltonlens/";
    license = licenses.mit;
  };
}
