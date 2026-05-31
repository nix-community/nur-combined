{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "jupyter-loopback";
  version = "0.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "jupyter-loopback";
    tag = "v${finalAttrs.version}";
    hash = "sha256-92C02SNX0xs8wGuC4lwmFsS1XZkRIDIlkr8P1YZo+Kg=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    jupyter-server
    tornado
  ];

  pythonRelaxDeps = [ "jupyter_loopback" ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
  ];

  meta = {
    description = "Make kernel-local HTTP/WS servers reachable from the notebook browser with zero user config";
    homepage = "https://github.com/banesullivan/jupyter-loopback";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
