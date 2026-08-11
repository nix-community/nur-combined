{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  torch,
  torchaudio,
  tqdm,
  asteroid-filterbanks,
  musdb,
  museval,
  stempeg,
  onnx,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "openunmix";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sigsep";
    repo = "open-unmix-pytorch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7jsyQhDUAeQmD+cvPoOUbxOW5YBlAoe+IjDebS+GXaw=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    torch
    torchaudio
    tqdm
  ];

  optional-dependencies = {
    asteroid = [
      asteroid-filterbanks
    ];
    evaluation = [
      musdb
      museval
    ];
    stempeg = [
      stempeg
    ];
    tests = [
      asteroid-filterbanks
      musdb
      museval
      onnx
      pytest
      stempeg
      tqdm
    ];
  };

  pythonImportsCheck = [
    "openunmix"
  ];

  meta = {
    description = "Open-Unmix - Music Source Separation for PyTorch";
    homepage = "https://github.com/sigsep/open-unmix-pytorch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
