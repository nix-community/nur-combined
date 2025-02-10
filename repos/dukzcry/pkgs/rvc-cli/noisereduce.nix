{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "noisereduce";
  version = "3.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/2Sij7kuPIHxU88pVQ5cLbVrJSOvqPVvXgPBd8xekY8=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    joblib
    matplotlib
    numpy
    scipy
    tqdm
  ];

  optional-dependencies = with python3.pkgs; {
    pytorch = [
      torch
    ];
  };

  pythonImportsCheck = [
    "noisereduce"
  ];

  meta = {
    description = "Noise reduction using Spectral Gating in Python";
    homepage = "https://pypi.org/project/noisereduce/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "noisereduce";
  };
}
