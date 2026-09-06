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
  version = "1.4.14-unstable-2026-09-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "FunASR";
    rev = "682ea10e80289faa2e2699d227b917950d0c2f8d";
    hash = "sha256-t7uRYrvHKZ/QOCXelJT6gdSxQL1OyLEpfEwiGF40818=";
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
