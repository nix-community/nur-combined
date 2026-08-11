{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  diffq,
  dora-search,
  einops,
  flake8,
  # hydra-colorlog,
  hydra-core,
  julius,
  # lameenc,
  museval,
  mypy,
  openunmix,
  pyyaml,
  soundfile,
  submitit,
  torch,
  torchaudio,
  tqdm,
  treetable,
}:

buildPythonPackage (finalAttrs: {
  pname = "demucs";
  # https://github.com/adefossez/demucs/blob/main/demucs/__init__.py
  version = "4.1.0a3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adefossez";
    repo = "demucs";
    rev = "b9ab48cad45976ba42b2ff17b229c071f0df9390";
    hash = "sha256-FkN7wIiO6xSYoAQBQHdxY92fV+1q3dvUPQu//oqhRhc=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/(.*?)>=.*/\1/' requirements.txt requirements_minimal.txt

    # quickfix: dont check deps
    echo >requirements.txt
    echo >requirements_minimal.txt
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    diffq
    dora-search
    einops
    flake8
    # hydra-colorlog
    hydra-core
    julius
    # lameenc
    museval
    mypy
    openunmix
    pyyaml
    soundfile
    submitit
    torch
    torchaudio
    tqdm
    treetable
  ];

  pythonImportsCheck = [
    "demucs"
  ];

  meta = {
    description = "Code for the paper Hybrid Spectrogram and Waveform Source Separation";
    homepage = "https://github.com/adefossez/demucs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
