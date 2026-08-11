{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "ten-vad";
  version = "1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TEN-framework";
    repo = "ten-vad";
    tag = "v${finalAttrs.version}-ONNX";
    hash = "sha256-G56HUgE5vZzBYfOQ/2wAAuWKpcT5gMgvg1bR6ePOEGI=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [
    "ten_vad"
  ];

  meta = {
    description = "Voice Activity Detector: low-latency, high-performance and lightweight";
    homepage = "https://github.com/TEN-framework/ten-vad";
    # unfree license: "You may not Deploy the ten-vad in a way that competes with Agora's offerings"
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ];
  };
})
