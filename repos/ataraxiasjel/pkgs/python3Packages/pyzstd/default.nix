{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  pytestCheckHook,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pyzstd";
  version = "0.16.2";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F5waLqFWWr8JxfL9cvnOfFSydkz3Np4FwL/Y8fZ/Y9I=";
  };

  build-system = [
    setuptools
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/Rogdham/pyzstd";
    description = "Python bindings to Zstandard (zstd) compression library";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
