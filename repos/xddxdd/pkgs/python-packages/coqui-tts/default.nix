{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  numpy,
  cython,
  scipy,
  torch,
  torchaudio,
  soundfile,
  librosa,
  scikit-learn,
  numba,
  inflect,
  tqdm,
  anyascii,
  pyyaml,
  fsspec,
  aiohttp,
  packaging,
  mutagen,
  flask,
  pysbd,
  umap-learn,
  pandas,
  matplotlib,
  trainer,
  coqpit,
  jieba,
  pypinyin,
  gruut,
  jamo,
  nltk,
  g2pkk,
  bangla,
  bnnumerizer,
  bnunicodenormalizer,
  einops,
  transformers,
  encodec,
  unidecode,
  num2words,
  spacy,
}:
buildPythonPackage (finalAttrs: {
  pname = "coqui-tts";
  version = "0.22.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "coqui-ai";
    repo = "TTS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RQVlPHYZ5X/6xbxwGNcgntcyAsBS8T2ketdk+OCIS3Q=";
  };
  build-system = [ setuptools ];

  # From requirements.txt
  propagatedBuildInputs = [
    numpy
    cython
    scipy
    torch
    torchaudio
    soundfile
    librosa
    scikit-learn
    numba
    inflect
    tqdm
    anyascii
    pyyaml
    fsspec
    aiohttp
    packaging
    mutagen

    # deps for examples
    flask

    # deps for inference
    pysbd

    # deps for notebooks
    umap-learn
    pandas

    # deps for training
    matplotlib

    # coqui stack
    trainer

    # config management
    coqpit

    # chinese g2p deps
    jieba
    pypinyin

    # # korean, dependency not available in nixpkgs
    # hangul_romanize

    # gruut+supported langs
    gruut

    # deps for korean
    jamo
    nltk
    g2pkk

    # deps for bangla
    bangla
    bnnumerizer
    bnunicodenormalizer

    #deps for tortoise
    einops
    transformers

    #deps for bark
    encodec

    # deps for XTTS
    unidecode
    num2words
    spacy
  ];

  pythonImportsCheck = [ "TTS" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Deep learning toolkit for Text-to-Speech, battle-tested in research and production";
    homepage = "http://coqui.ai";
    license = with lib.licenses; [ mpl20 ];
    # Did not complete packaging due to broken triton dependency
    broken = true;
  };
})
