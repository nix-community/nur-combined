{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  unstableGitUpdater,
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
  version = "1.4.14-unstable-2026-09-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "FunASR";
    rev = "130e57a6fdb9661e2b0cc59199fb31ef81f2b9e9";
    hash = "sha256-x+I2xxtrqTEdakMQwF4UhLIiDbcafTtpOE9vf05H21k=";
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

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/modelscope/FunASR";
    tagPrefix = "v";
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
