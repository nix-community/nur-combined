{ lib
, buildPythonPackage
, fetchPypi
, asteval
, numpy
, scipy
, setuptools-scm
, uncertainties
}:

buildPythonPackage rec {
  pname = "lmfit";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0GfD6lAfA1r108B55ubjXcPMGsfUOUKaQlsK61p4WKI=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  
  propagatedBuildInputs = [ asteval numpy scipy uncertainties ];

  doCheck = false;

  pythonImportsCheck = [ "lmfit" ];

  meta = with lib; {
    description = "Non-Linear Least-Squares Minimization and Curve-Fitting for Python";
    homepage = "https://lmfit.github.io/lmfit-py/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ smaret ];
  };
}
