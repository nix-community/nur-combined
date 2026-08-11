{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  ipython,
  librosa,
  matplotlib,
  music21,
  numba,
  numpy,
  pandas,
  pretty-midi,
  soundfile,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "libfmp";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meinardmueller";
    repo = "libfmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SWyP+3Ubvg3G9OvOBh5zBRXGgc+83+GAPnWcKykpU1M=";
  };

  postPatch = ''
    # unpin dependencies
    substituteInPlace setup.py \
      --replace "ipython >= 8.10.0, < 9.0.0" "ipython"
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    ipython
    librosa
    matplotlib
    music21
    numba
    numpy
    pandas
    pretty-midi
    soundfile
    scipy
  ];

  pythonImportsCheck = [
    "libfmp"
  ];

  meta = {
    description = "Libfmp - Python package for teaching and learning Fundamentals of Music Processing (FMP";
    homepage = "https://github.com/meinardmueller/libfmp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
