{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  bottle,
  bottle-cors,
  paste,
  grpcio,
  grpcio-tools,
  twine,
}:

buildPythonPackage rec {
  pname = "cygrpc";
  version = "1.0.4.post6";
  pyproject = true;

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5vFR4qQzM3qKVxsOwWWo3E4d49HAWHpe5WXSa2DQWMY=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "==1.23.0" ""
  '';

  build-system = [
    setuptools
    # wheel
    # twine
  ];

  dependencies = [
    bottle
    bottle-cors
    paste
    grpcio
    grpcio-tools
    twine
  ];

  meta = with lib; {
    homepage = "https://github.com/cuemby/python-cygrpc";
    description = "Micro-Framwork for gRPC with REST expose support";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
