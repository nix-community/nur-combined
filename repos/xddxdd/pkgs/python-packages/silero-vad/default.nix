{
  stdenv,
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

  # onnxruntime may fail to start on ARM64
  pythonImportsCheck = lib.optionals stdenv.isx86_64 [ "silero_vad" ];

  meta = {
    changelog = "https://github.com/snakers4/silero-vad/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Pre-trained enterprise-grade Voice Activity Detector";
    homepage = "https://github.com/snakers4/silero-vad";
    license = with lib.licenses; [ mit ];
  };
}
