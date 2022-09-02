{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "s2sphere";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "sidewalklabs";
    repo = "s2sphere";
    rev = "d1d067e8c06e5fbaf0cc0158bade947b4a03a438";
    hash = "sha256-6hNIuyLTcGcXpLflw2ajCOjel0IaZSFRlPFi81Z5LUo=";
  };

  propagatedBuildInputs = with python3Packages; [ future ];

  doCheck = false;

  pythonImportsCheck = [ "s2sphere" ];

  meta = with lib; {
    description = "Python implementation of the S2 geometry library";
    homepage = "http://s2sphere.sidewalklabs.com/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
