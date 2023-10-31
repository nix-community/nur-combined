{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, jwcrypto
, ...
}:

buildPythonPackage rec {
  pname = "python-jwt";
  version = "4.0.0";
  pyproject = true;

  src = fetchPypi {
    pname = "python_jwt";
    inherit version;
    hash = "sha256-ISAtE9ILCP7UZs3km4hDNdl/ftbUbBUMbS1UL47f/F0=";
  };

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
