{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  stdenv,
  setuptools,
  # Dependencies
  editdistance,
  hydra-core,
  jaconv,
  jamo,
  jieba,
  kaldiio,
  librosa,
  modelscope,
  onnx,
  onnxconverter-common,
  oss2,
  pydub,
  pytorch-wpe,
  pyyaml,
  rapidfuzz,
  requests,
  scipy,
  sentencepiece,
  soundfile,
  tensorboardx,
  tiktoken,
  torch-complex,
  torchaudio,
  tqdm,
  umap-learn,
  websockets,
}:
buildPythonPackage (finalAttrs: {
  pname = "funasr";
  version = "1.4.3-unstable-2026-08-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "FunASR";
    rev = "8c60d278379de0044a9211a04660c9eeba08c66c";
    hash = "sha256-F7J4/+/u8thON3fJ8H1sajwVtpA43z23emv5kotMPn8=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    editdistance
    hydra-core
    jaconv
    jamo
    jieba
    kaldiio
    librosa
    modelscope
    onnx
    onnxconverter-common
    oss2
    pydub
    pytorch-wpe
    pyyaml
    rapidfuzz
    requests
    scipy
    sentencepiece
    soundfile
    tensorboardx
    tiktoken
    torch-complex
    torchaudio
    tqdm
    umap-learn
    websockets
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail '"pytest-runner",' ""
  '';

  pythonImportsCheck = [ "funasr" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fundamental End-to-End Speech Recognition Toolkit and Open Source SOTA Pretrained Models";
    homepage = "https://www.funasr.com/";
    license = with lib.licenses; [ mit ];
    mainProgram = "funasr";
    # Dependency librosa doesn't work on ARM64
    broken = stdenv.hostPlatform.isAarch64;
  };
})
