{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "textstat";
  version = "0.7.3";

  format = "setuptools";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
  };

  propagatedBuildInputs = [
    python3Packages.pyphen
    python3Packages.setuptools
  ];

  pythonImportsCheck = [
    "textstat"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Calculate statistical features from text";
    homepage = "https://pypi.org/project/textstat/";
    license = licenses.mit;
  };
}
