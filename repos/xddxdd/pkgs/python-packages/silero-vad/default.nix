{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  buildPythonPackage,
  # Dependencies
  hatchling,
  onnxruntime,
  torch,
  torchaudio,
}:
buildPythonPackage (finalAttrs: {
  pname = "silero-vad";
  version = "6.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "snakers4";
    repo = "silero-vad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-peGaJkSqjeobgx479OKt8ErorFviTIA7naFPewgab4U=";
  };
  pythonRelaxDeps = true;

  propagatedBuildInputs = [
    hatchling
    onnxruntime
    torch
    torchaudio
  ];

  # onnxruntime may fail to start on ARM64
  pythonImportsCheck = lib.optionals stdenv.hostPlatform.isx86_64 [ "silero_vad" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/snakers4/silero-vad/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Pre-trained enterprise-grade Voice Activity Detector";
    homepage = "https://github.com/snakers4/silero-vad";
    license = with lib.licenses; [ mit ];
  };
})
