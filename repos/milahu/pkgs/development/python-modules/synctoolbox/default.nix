{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "synctoolbox";
  version = "1.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "meinardmueller";
    repo = "synctoolbox";
    # tag = "v${finalAttrs.version}";
    # https://github.com/meinardmueller/synctoolbox/pull/40
    rev = "bac9f597ab549b602de4cabbdcf67d008c7781ec";
    hash = "sha256-wWes+YYEVh1qczqcFFNc/o5TobA3Q378Xlgfwh9o+EU=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/ >= .*, < .*",$/",/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.flit-core
  ];

  dependencies = with python3.pkgs; [
    libfmp
    librosa
    matplotlib
    music21
    numba
    numpy
    pandas
    pretty-midi
    scipy
    soundfile
  ];

  optional-dependencies = with python3.pkgs; {
    develop = [
      flit
      ipython
      jupyter
      nbstripout
    ];
    doc = [
      sphinx
      sphinx-rtd-theme
    ];
    test = [
      pytest
    ];
  };

  pythonImportsCheck = [
    "synctoolbox"
  ];

  meta = {
    description = "Sync Toolbox - Python package with reference implementations for efficient, robust, and accurate music synchronization based on dynamic time warping (DTW";
    homepage = "https://github.com/meinardmueller/synctoolbox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "synctoolbox";
  };
})
