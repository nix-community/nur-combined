{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  hatchling,
  onnxruntime,
  torch,
  torchaudio,
}:
buildPythonPackage rec {
  inherit (sources.silero-vad) pname version src;
  pyproject = true;

  pythonRelaxDeps = true;

  propagatedBuildInputs = [
    hatchling
    onnxruntime
    torch
    torchaudio
  ];

  # onnxruntime may fail to start in sandbox, disable check if onnxruntime does too
  pythonImportsCheck = lib.optionals onnxruntime.doCheck [ "silero_vad" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Pre-trained enterprise-grade Voice Activity Detector";
    homepage = "https://github.com/snakers4/silero-vad";
    license = with lib.licenses; [ mit ];
  };
}
