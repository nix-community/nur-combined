{
  stdenv,
  piper-tts-native,
  lib,
  buildPythonPackage,
  # Dependencies
  piper-phonemize,
  onnxruntime,
}:
buildPythonPackage rec {
  inherit (piper-tts-native) pname version src;
  sourceRoot = "source/src/python_run";

  propagatedBuildInputs = [
    piper-phonemize
    onnxruntime
  ];

  # onnxruntime may fail to start on ARM64
  pythonImportsCheck = lib.optionals stdenv.isx86_64 [ "piper" ];

  meta = {
    mainProgram = "piper";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python component for piper-tts";
    inherit (piper-tts-native.meta) homepage license;
  };
}
