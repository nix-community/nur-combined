{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "daltonlens";
  version = "0.1.5";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
    pillow
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
