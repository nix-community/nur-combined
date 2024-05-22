{ lib
, python3
, ffmpeg
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "audalign";
  version = "1.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "benfmiller";
    repo = "audalign";
    rev = "v${version}";
    hash = "sha256-ldB4TxXfkmbTeslwARTjzrra+Xt+NZOeiFwrslIAEPc=";
  };

  postPatch = ''
    # unpin versions
    sed -i 's/==.*//' requirements.txt
    # fix import check
    # fix: cannot cache function 'x': no locator available
    export NUMBA_CACHE_DIR=$TMP
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    ffmpeg
  ] ++ (with python3.pkgs; [
    appdirs
    attrs
    audioread
    certifi
    cffi
    charset-normalizer
    contourpy
    cycler
    decorator
    exceptiongroup
    execnet
    fonttools
    idna
    imageio
    iniconfig
    joblib
    kiwisolver
    librosa
    llvmlite
    matplotlib
    networkx
    noisereduce
    numba
    numpy
    packaging
    pillow
    pluggy
    pooch
    pycparser
    pydub
    pyparsing
    python-dateutil
    pywavelets
    requests
    resampy
    scikit-image
    scikit-learn
    scipy
    six
    soundfile
    threadpoolctl
    tifffile
    tomli
    tqdm
    urllib3
  ]);

  pythonImportsCheck = [ "audalign" ];

  meta = with lib; {
    description = "Package for aligning audio files through audio fingerprinting";
    homepage = "https://github.com/benfmiller/audalign";
    changelog = "https://github.com/benfmiller/audalign/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
