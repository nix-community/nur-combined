{
  lib,
  sources,
  buildPythonPackage,
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
  requests,
  scipy,
  sentencepiece,
  soundfile,
  tensorboardx,
  torch-complex,
  torchaudio,
  tqdm,
  umap-learn,
}:
buildPythonPackage rec {
  inherit (sources.funasr) pname version src;

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
    requests
    scipy
    sentencepiece
    soundfile
    tensorboardx
    torch-complex
    torchaudio
    tqdm
    umap-learn
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail '"pytest-runner",' ""
  '';

  pythonImportsCheck = [ "funasr" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fundamental End-to-End Speech Recognition Toolkit and Open Source SOTA Pretrained Models";
    homepage = "https://www.funasr.com/";
    license = with lib.licenses; [ mit ];
  };
}
