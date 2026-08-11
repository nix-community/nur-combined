{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  bitstring,
  librosa,
  matplotlib,
  numpy,
  pandas,
  pillow,
  praat-parselmouth,
  pydub,
  pyloudnorm,
  pyrubberband,
  pywavelets,
  pyyaml,
  scikit-learn,
  soundfile,
  sox,
  tabulate,
  tensorboard,
  torch,
  torchaudio,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "resemble-perth";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "resemble-ai";
    repo = "Perth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nW+O6DI4Bnf6TkX9fWCAQNWOYIaBHN4qf4gSgy7Y2WU=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/(>=|==).*//' requirements.txt
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    bitstring
    librosa
    matplotlib
    numpy
    pandas
    pillow
    praat-parselmouth
    pydub
    pyloudnorm
    pyrubberband
    pywavelets
    pyyaml
    scikit-learn
    soundfile
    sox
    tabulate
    tensorboard
    torch
    torchaudio
    tqdm
  ];

  pythonImportsCheck = [
    # fix import check: RuntimeError: cannot cache function '__o_fold': no locator available for file
    # NUMBA_DISABLE_CACHING = 1;
    # "perth"
  ];

  meta = {
    description = "Open Audio Watermarking Tool";
    homepage = "https://github.com/resemble-ai/Perth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
