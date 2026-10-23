{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  huggingface-hub,
  numpy,
  onnxruntime,
  soundfile,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "supertonic";
  version = "1.3.1";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "supertone-inc";
    repo = "supertonic-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FEs511UjMTkgDptxDuBNUTkhTwuv/vp3R3cDfApsNKA=";
  };

  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    numpy
    onnxruntime
    soundfile
  ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  # Need the model from Hugging Face.
  disabledTestPaths = [ "tests/test_pipeline.py" ];
  disabledTests = [
    "test_cmd_info"
    "test_cmd_list_voices"
  ];

  pythonImportsCheck = [ "supertonic" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight on-device text-to-speech with ONNX Runtime";
    homepage = "https://github.com/supertone-inc/supertonic-py";
    changelog = "https://github.com/supertone-inc/supertonic-py/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
