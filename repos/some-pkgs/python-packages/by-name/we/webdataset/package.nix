{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, braceexpand
, numpy
, pyyaml
}:

buildPythonPackage rec {
  pname = "webdataset";
  version = "0.2.73";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "webdataset";
    repo = "webdataset";
    rev = version;
    hash = "sha256-Lk84rIDWDhYKwDXjW5OQ7dSFm4kSmVrIiIxK6AXKlUU=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    braceexpand
    numpy
    pyyaml
  ];

  pythonImportsCheck = [ "webdataset" ];

  meta = with lib; {
    description = "A high-performance Python-based I/O system for large (and small) deep learning problems, with strong support for PyTorch";
    homepage = "https://github.com/webdataset/webdataset";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
