{
  fetchPypi,
  lib,
  nix-update-script,

  # python packages
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (final: {
  pname = "pylsqpack";
  version = "1.1.2";
  pyproject = true;

  # the sdist includes the vendored ls-qpack sources
  src = fetchPypi {
    inherit (final) pname version;
    hash = "sha256-hkInC5VfU5Dby57hkxc1HTPKI+mRfhWrnRd75KA/Nw4=";
  };

  build-system = [
    setuptools
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [ "pylsqpack" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "${final.pname}-latest"
    ];
  };

  meta = {
    description = "Python wrapper for the ls-qpack QPACK library";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    homepage = "https://github.com/aiortc/pylsqpack";
    changelog = "https://github.com/aiortc/pylsqpack/releases/tag/${final.version}";
    downloadPage = "https://pypi.org/project/pylsqpack/#files";
  };
})
