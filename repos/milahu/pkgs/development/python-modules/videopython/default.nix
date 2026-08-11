{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "videopython";
  version = "0.26.1-d74aa7c";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BartWojtowicz";
    repo = "videopython";

    # tag = finalAttrs.version;
    # hash = "sha256-nGoo/8gJu7ppVlazMnGxBXjHlLFCp3IGF7FKQ3g0Wxs=";

    # https://github.com/BartWojtowicz/videopython/pull/225
    # https://github.com/BartWojtowicz/videopython/pull/226
    # https://github.com/BartWojtowicz/videopython/pull/227
    rev = "d74aa7ca1a2d3f40144872eac066ffee4f738982";
    hash = "sha256-EyrDaEnJGshFUpvveQ/pBXv/RqSe3p+MD6XlAQIQEic=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    numpy
    opencv-python-headless
    pillow
    pydantic
    tqdm

    # "optional" dependencies
    /*
    accelerate
    # chatterbox-tts
    # demucs
    diffusers
    easyocr
    hf-transfer
    numba
    ollama
    openai-whisper
    pyannote-audio
    scikit-learn
    scipy
    sentencepiece
    torch
    torchaudio
    transformers
    # transnetv2-pytorch
    ultralytics
    */
    torch
    openai-whisper
    transformers
    sentencepiece
    demucs
    chatterbox-tts
  ];

  /*
  optional-dependencies = with python3.pkgs; {
    ai = [
      accelerate
      chatterbox-tts
      demucs
      diffusers
      easyocr
      hf-transfer
      numba
      ollama
      openai-whisper
      pyannote-audio
      scikit-learn
      scipy
      sentencepiece
      torch
      torchaudio
      transformers
      transnetv2-pytorch
      ultralytics
    ];
  };
  */

  pythonImportsCheck = [
    "videopython"
  ];

  checkPhase = ":";

  meta = {
    description = "Minimal video generation and processing library";
    homepage = "https://github.com/BartWojtowicz/videopython";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "videopython";
  };
})
