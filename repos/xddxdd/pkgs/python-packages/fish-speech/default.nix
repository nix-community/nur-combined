{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  cachetools,
  datasets,
  einops,
  einx,
  faster-whisper,
  funasr,
  gradio,
  grpcio,
  hydra-core,
  kui,
  librosa,
  loguru,
  loralib,
  modelscope,
  natsort,
  numpy,
  opencc-python-reimplemented,
  ormsgpack,
  pyaudio,
  pydantic,
  pydub,
  pytorch-lightning,
  resampy,
  rich,
  setuptools-scm,
  silero-vad,
  tensorboard,
  tiktoken,
  torch,
  transformers,
  uvicorn,
  vector-quantize-pytorch,
  wandb,
  zstandard,
}:
let
  lightning = pytorch-lightning.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pytorch-lightning ];
    preConfigure = lib.replaceStrings [ "pytorch" ] [ "lightning" ] old.preConfigure;
    pythonImportsCheck = [ "lightning" ];
  });
in
buildPythonPackage rec {
  inherit (sources.fish-speech) pname version src;
  pyproject = true;

  pythonRelaxDeps = true;

  postPatch = ''
    sed -i "/pyrootutils/d" pyproject.toml

    find . -name \*.py -exec sed -i \
      -e "/pyrootutils/d" \
      {} \;
  '';

  propagatedBuildInputs = [
    cachetools
    datasets
    einops
    einx
    faster-whisper
    funasr
    gradio
    grpcio
    hydra-core
    kui
    librosa
    lightning
    loguru
    loralib
    modelscope
    natsort
    numpy
    opencc-python-reimplemented
    ormsgpack
    pyaudio
    pydantic
    pydub
    resampy
    rich
    setuptools-scm
    silero-vad
    tensorboard
    tiktoken
    torch
    transformers
    uvicorn
    vector-quantize-pytorch
    wandb
    zstandard
  ];

  postInstall = ''
    mkdir -p $out/bin
    for F in tools/*.py; do
      CMD=$(basename "$F")
      CMD=''${CMD%.py}
      makeWrapper $(command -v -- python) $out/bin/fish-speech-$CMD \
        --suffix PYTHONPATH : "$PYTHONPATH" \
        --add-flags "-m tools.$CMD"
    done
  '';

  pythonImportsCheck = [ "fish_speech" ];

  meta = {
    mainProgram = "fish-speech-api";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SOTA Open Source TTS";
    homepage = "https://speech.fish.audio/";
    license = with lib.licenses; [ cc-by-nc-sa-40 ];
    # # Fish-speech requires CUDA
    # broken = !torch.cudaSupport;
    # FIXME: dependency package kui is broken
    broken = true;
  };
}
