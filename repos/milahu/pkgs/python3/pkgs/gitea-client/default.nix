{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, certifi
, python-dateutil
, six
, urllib3
, pysocks
}:

buildPythonPackage rec {
  pname = "gitea-client";
  version = "unstable-2024-07-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "gitea-client-python";
    rev = "4f3d6e2d9d25edce4a99ea7cf13c6c4baa061e08";
    hash = "sha256-+zo7S+Uix52uKDGjPaQccGBoUFwJstk4SSCWJrG+nZ4=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    certifi
    python-dateutil
    setuptools
    six
    urllib3
    pysocks
  ];

  pythonImportsCheck = [ "gitea_client" ];

  meta = with lib; {
    description = "gitea API client in python";
    homepage = "https://github.com/milahu/gitea-client-python";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
