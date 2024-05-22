{ lib
, python3
, fetchFromGitHub
, pandoc
}:

python3.pkgs.buildPythonApplication rec {
  pname = "syncstart";
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rpuntaie";
    repo = "syncstart";
    #rev = "v${version}";
    # fix install https://github.com/rpuntaie/syncstart/issues/13
    rev = "0c4794f8a3865ee209842ef01fa3ec94d1b065a9";
    hash = "sha256-q48Y5CwWgv5EXYnrrdSba6qSk3UxZQe1rNbqXnJBVbU=";
  };

  # fix:
  # Checking runtime dependencies for syncstart-1.1.0-py3-none-any.whl
  #   - python-opencv not installed
  postPatch = ''
    substituteInPlace setup.py \
      --replace-warn ",'opencv-python'" ""
  '';

  nativeBuildInputs = (with python3.pkgs; [
    setuptools
    wheel
  ]) ++ [
    # needed to build manpage
    pandoc
  ];

  buildInputs = with python3.pkgs; [
    # needed to build manpage
    stpl
  ];

  checkInputs = with python3.pkgs; [
    restview
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
    scipy
    matplotlib
    opencv4 # opencv-python
  ];

  pythonImportsCheck = [ "syncstart" ];

  meta = with lib; {
    description = "Calculate the cut needed at start to sync two media files";
    homepage = "https://github.com/rpuntaie/syncstart";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "syncstart";
  };
}
