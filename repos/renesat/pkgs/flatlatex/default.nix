{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  regex,
}:
buildPythonPackage rec {
  pname = "flatlatex";
  version = "0.15";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "jb-leger";
    repo = "flatlatex";
    rev = "v${version}";
    hash = "sha256-cC3Ip3n4wHb7KGun0O1IRup31nf/wo4+B0jegzqLxK4=";
  };

  dependencies = [
    regex
  ];

  pythonImportsCheck = [
    "flatlatex"
  ];

  meta = with lib; {
    description = "A LaTeX math converter to unicode text ";
    homepage = "https://github.com/jb-leger/flatlatex";
    license = licenses.bsd2;
    maintainers = with maintainers; [renesat];
  };
}
