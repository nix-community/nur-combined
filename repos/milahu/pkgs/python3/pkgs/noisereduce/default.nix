{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "noisereduce";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "timsainb";
    repo = "noisereduce";
    rev = "v${version}";
    hash = "sha256-/56QEB//akfoBJ/QSHjfQeOvnvNbf4y9fboZDTIYSJw=";
  };

  postPatch = ''
    # fix import check
    # fix: cannot cache function 'x': no locator available
    export NUMBA_CACHE_DIR=$TMP 
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    #coverage
    librosa
    matplotlib
    numpy
    #pytest
    #pytest-cov
    #pytest-ordering
    #python-coveralls # removed, since it is no longer maintained and broken
    scipy
    torch
    tqdm
  ];

  pythonImportsCheck = [ "noisereduce" ];

  meta = with lib; {
    description = "Noise reduction in python using spectral gating. speech, bioacoustics, audio, time-domain signals";
    homepage = "https://github.com/timsainb/noisereduce";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
