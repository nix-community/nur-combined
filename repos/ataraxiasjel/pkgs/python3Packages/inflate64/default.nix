{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "inflate64";
  version = "1.0.3";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qJ7dQWw27aDDpdMvMf8VVdssWjiEqo35XoZ5+CA+Eu4=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://codeberg.org/miurahr/inflate64";
    description = "deflate64 compression/decompression library";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
