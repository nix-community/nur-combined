{
  lib,
  buildPythonPackage,
  fetchPypi,
  asteval,
  dill,
  numpy,
  scipy,
  setuptools,
  setuptools-scm,
  uncertainties,
}:

buildPythonPackage rec {
  pname = "lmfit";
  version = "1.3.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-czIea4gfL2hiNXIaffwCr2uw8DCiXv62Zjj2KxxgU6E=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asteval
    dill
    numpy
    scipy
    uncertainties
  ];

  doCheck = false;

  pythonImportsCheck = [ "lmfit" ];

  meta = with lib; {
    changelog = "https://github.com/lmfit/lmfit-py/releases/tag/${version}";
    description = "Non-Linear Least-Squares Minimization and Curve-Fitting for Python";
    homepage = "https://lmfit.github.io/lmfit-py/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ smaret ];
  };
}
