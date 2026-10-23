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
  version = "1.4.16-unstable-2026-10-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "FunASR";
    rev = "fbbfe01800a8c4c9103cb2150fb1a5d06cc64758";
    hash = "sha256-1IgcLUw7J49a4oQGWEJiYIRnwg4IoiSgFJ/yaQgcCa8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
    tagFormat = "v[0-9]*";
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
