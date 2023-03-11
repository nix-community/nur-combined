{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "textstat";
  version = "0.7.3";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pyphen
    setuptools
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
