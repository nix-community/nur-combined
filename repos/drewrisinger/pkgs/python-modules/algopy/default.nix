{ lib
, buildPythonPackage
, fetchPypi
, mpmath
, numpy
, scipy
  # test inputs
, pytestCheckHook
, nose
}:

buildPythonPackage rec {
  pname = "algopy";
  version = "0.5.7";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
    sha256 = "6955f676fce3858fa3585cb7f3f7e1796cb93377d24016419b6699291584b7df";
  };

  propagatedBuildInputs = [
    mpmath
    numpy
    scipy
  ];

  doCheck = false;  # tests are out of date, rely on numpy. Would require a near-total rewrite of the tests to fix.
  pythonImportsCheck = [ "algopy" ];

  meta = with lib; {
    description = "Research Prototype for Algorithmic Differentation in Python";
    homepage = "https://pythonhosted.org/algopy/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
