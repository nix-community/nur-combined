{
  lib,
  fetchFromGitHub,
  python312Packages,
}:

python312Packages.buildPythonPackage {
  pname = "s2sphere";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "sidewalklabs";
    repo = "s2sphere";
    rev = "d1d067e8c06e5fbaf0cc0158bade947b4a03a438";
    hash = "sha256-6hNIuyLTcGcXpLflw2ajCOjel0IaZSFRlPFi81Z5LUo=";
  };

  dependencies = with python312Packages; [ future ];

  doCheck = false;

  pythonImportsCheck = [ "s2sphere" ];

  meta = {
    description = "Python implementation of the S2 geometry library";
    homepage = "http://s2sphere.sidewalklabs.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
