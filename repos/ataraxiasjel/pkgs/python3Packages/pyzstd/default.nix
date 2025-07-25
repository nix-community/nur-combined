{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  zstd-c,
  typing-extensions,
  pytestCheckHook,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pyzstd";
  version = "0.17.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2EJx+LqmbEGSBMHdEVpN7Ismb4opIdohuBdk+iCMHbY=";
  };

  postPatch = ''
    # pyzst specifies setuptools<74 because 74+ drops `distutils.msvc9compiler`,
    # required for Python 3.9 under Windows
    substituteInPlace pyproject.toml \
        --replace-fail '"setuptools>=64,<74"' '"setuptools"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    typing-extensions
    zstd-c
  ];

  pypaBuildFlags = [
    "--config-setting=--global-option=--dynamic-link-zstd"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "pyzstd"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/Rogdham/pyzstd";
    description = "Python bindings to Zstandard (zstd) compression library";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
