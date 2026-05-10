{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  matplotlib,
  numpy,
  pydub,
  scipy,
  setuptools,
  tqdm,
  noisereduce,
  torch,
  pytest,
  pytest-xdist,
  pillow,
  scikit-image,
}:

buildPythonPackage (finalAttrs: {
  pname = "audalign";
  version = "1.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "benfmiller";
    repo = "audalign";
    # tag = "v${finalAttrs.version}";
    # https://github.com/benfmiller/audalign/pull/70
    rev = "a281758a0aceae9fd1276d150bf8424cdd05a1ac";
    hash = "sha256-Tyd0xRo7zW3wbKGWWBoqrIj29LyfG1CyUMbHl9JprTk=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i 's/==.*",/",/' pyproject.toml
  '';

  build-system = [
    hatchling
  ];

  dependencies = [
    matplotlib
    numpy
    pydub
    scipy
    setuptools
    tqdm

    # option "visrecognize" for audalign.VisualRecognizer and audalign.fine_align
    pillow
    scikit-image
  ];

  optional-dependencies = {
    noisereduce = [
      noisereduce
      torch
    ];
    test = [
      pytest
      pytest-xdist
    ];
    /*
    visrecognize = [
      pillow
      scikit-image
    ];
    */
  };

  pythonImportsCheck = [
    "audalign"
  ];

  meta = {
    description = "Package for aligning audio files through audio fingerprinting";
    homepage = "https://github.com/benfmiller/audalign";
    changelog = "https://github.com/benfmiller/audalign/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
