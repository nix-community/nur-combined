{ lib
, buildPythonPackage
, callPackage
, setuptools
, wheel
, jwcrypto
, ...
}:

let
  sources = (callPackage ../../_sources/generated.nix { }).python-jwt;
in
buildPythonPackage {
  pname = "python-jwt";
  inherit (sources) version src;
  pyproject = true;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    jwcrypto
  ];

  pythonImportsCheck = [ "python_jwt" ];

  meta = with lib; {
    description = "Module for generating and verifying JSON Web Tokens";
    homepage = "https://pypi.org/project/python-jwt/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
