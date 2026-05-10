{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "music21";
  version = "9.9.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cuthbertLab";
    repo = "music21";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DrO8XRTpYiF51L/2HlUHXxHtgEJ7/cG9VgdUoWkYhGE=";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    chardet
    joblib
    jsonpickle
    matplotlib
    more-itertools
    numpy
    requests
    webcolors
  ];

  pythonImportsCheck = [
    "music21"
  ];

  meta = {
    description = "Music21: a Toolkit for Computer-Aided Musical Analysis and Computational Musicology";
    homepage = "https://github.com/cuthbertLab/music21";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "music21";
  };
})
