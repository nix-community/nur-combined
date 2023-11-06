{ buildPythonPackage
, fetchPypi
, setuptools
, setuptools-git
, numpy
, pillow
, nix-update-script
}: buildPythonPackage rec {
  pname = "daltonlens";
  version = "0.1.5";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-git
  ];

  propagatedBuildInputs = [
    numpy
    pillow
  ];

  pythonImportsCheck = [ "daltonlens" ];

  passthru.updateScript = nix-update-script { };
}
