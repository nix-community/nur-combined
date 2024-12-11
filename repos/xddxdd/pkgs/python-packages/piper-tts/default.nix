{
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

  # onnxruntime may fail to start in sandbox, disable check if onnxruntime does too
  pythonImportsCheck = lib.optionals onnxruntime.doCheck [ "piper" ];

  meta = {
    mainProgram = "piper";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python component for piper-tts";
    inherit (piper-tts-native.meta) homepage license;
  };
}
