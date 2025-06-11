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

buildPythonPackage rec {
  pname = "aioice";
  version = "0.10.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XI4UIhA0SNFxklxnj7OXleX+E9eRCL67AKp1qJnCCUo=";
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
}
