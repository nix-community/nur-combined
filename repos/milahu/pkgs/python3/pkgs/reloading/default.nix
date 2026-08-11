{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "reloading";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "julvo";
    repo = "reloading";
    rev = "v${version}";
    hash = "sha256-7DB6akaLZTzHlYFUbYNJhxmkSyTUqCdhrKeD+nri2/E=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "reloading" ];

  meta = with lib; {
    description = "Change Python code while it's running without losing state";
    homepage = "https://github.com/julvo/reloading";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
