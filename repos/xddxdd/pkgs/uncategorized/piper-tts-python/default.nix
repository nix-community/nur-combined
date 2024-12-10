{
  piper-tts,
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (piper-tts) pname version src;
  sourceRoot = "source/src/python_run";

  propagatedBuildInputs = with python3Packages; [
    piper-phonemize
    onnxruntime
  ];

  pythonImportsCheck = [
    "piper"
  ];

  meta = {
    mainProgram = "piper";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python component for piper-tts";
    inherit (piper-tts.meta) homepage license;
  };
}
