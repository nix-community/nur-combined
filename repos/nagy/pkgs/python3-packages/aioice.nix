{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  dnspython,
  ifaddr,
  coverage,
  mypy,
  pyopenssl,
  ruff,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioice";
  version = "0.15.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-xYXgz6ZmRqYXFT1fERgUpOxH374cz6TXwfYViGbe548=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    dnspython
    ifaddr
  ];

  optional-dependencies = {
    dev = [
      coverage
      mypy
      pyopenssl
      ruff
      websockets
    ];
  };

  pythonImportsCheck = [
    "aioice"
  ];

  meta = {
    description = "Implementation of Interactive Connectivity Establishment (RFC 5245)";
    homepage = "https://pypi.org/project/aioice";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "aioice";
  };
})
