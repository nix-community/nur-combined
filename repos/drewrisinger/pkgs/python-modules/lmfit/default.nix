{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, asteval
, numpy
, scipy
, uncertainties
  # test inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "lmfit";
  version = "1.0.1";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "lmfit";
    repo = "lmfit-py";
    rev = version;
    sha256 = "12raczrn1czlc9iv7nsghdnph03zi39794030kwll6qssl4a9k7w";
  };

  propagatedBuildInputs = [
    asteval
    numpy
    scipy
    uncertainties
  ];

  pythonImportsCheck = [ "lmfit" ];
  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "Non-linear least-squares minimization, with flexible parameter settings";
    longDescription = "Based on scipy.optimize.leastsq and with many additional classes and methods for curve fitting";
    homepage = "https://lmfit.github.io/lmfit-py/index.html";
    downloadPage = "https://github.com/lmfit/lmfit-py/releases";
    license = licenses.bsd3;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
