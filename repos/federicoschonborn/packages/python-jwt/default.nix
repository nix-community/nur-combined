{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, cryptography
}:

buildPythonPackage rec {
  pname = "jwt";
  version = "1.3.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qe/yLLszcqDNXP3oZYc8OO6O3vkZSNRl998fMVIlOf4=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    cryptography
  ];

  pythonImportsCheck = [
    "jwt"
  ];

  meta = {
    description = "JSON Web Token library for Python 3";
    homepage = "https://pypi.org/project/jwt/";
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
