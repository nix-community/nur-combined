{ lib
, buildPythonPackage
, fetchFromGitHub
, python3
, cycler
, numpy
, stt
, joblib
, kiwisolver
, pydub
, pyparsing
, python-dateutil
, scikit-learn
, scipy
, six
, tqdm
}:

buildPythonPackage rec {
  pname = "autosub";
  version = "1.1.0";

  # https://github.com/abhirooptalasila/AutoSub/pull/75
  # Add support for Python 3.10
  # remove DeepSpeech
  # update the getmodels.sh script to easily download Coqui models
  # https://github.com/KyleMaas/AutoSub/tree/add-support-for-python-3.10
  src = fetchFromGitHub {
    owner = "KyleMaas";
    repo = "AutoSub";
    rev = "8ab99377c23ef28f86d64e69d373e04266081429";
    sha256 = "sha256-bRwa0YYkWGe45aQjpXauS6Pf1UvGQs2LAGjrW4fcZmM=";
  };

  # https://github.com/milahu/autosub-by-abhirooptalasila
  # fix: ModuleNotFoundError: No module named 'logger'
  # fix: ModuleNotFoundError: No module named 'utils'
  # fix: ModuleNotFoundError: No module named 'writeToFile'
  # ...
  # these were fixed by https://github.com/abhirooptalasila/AutoSub/pull/54
  # but pull/75  causes regression
  # https://github.com/abhirooptalasila/AutoSub/pull/75/files#r1317124605
  postPatch = ''
    sed -i '
      s/^import logger/from . import logger/;
      s/^import trainAudio/from . import trainAudio/;
      s/^import featureExtraction/from . import featureExtraction/;
      s/^from utils import/from .utils import/;
      s/^from writeToFile import/from .writeToFile import/;
      s/^from audioProcessing import/from .audioProcessing import/;
      s/^from segmentAudio import/from .segmentAudio import/;
    ' autosub/*.py
  '';

  # relax requirements
  # fix: ERROR: Package 'autosub' requires a different Python: 3.10.12 not in '<=3.10'
  # setup.py:    python_requires='<=3.10',
  preBuild = ''
    sed -i 's/==.*$//' requirements.txt
    sed -i '/python_requires=/d' setup.py
  '';

  postInstall = ''
    patchShebangs getmodels.sh
    cp getmodels.sh $out/bin/autosub-getmodels
  '';

  # fix: WARNING: Testing via this command is deprecated and will be removed in a future version.
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';

  propagatedBuildInputs = [
    cycler
    numpy
    stt
    joblib
    kiwisolver
    pydub
    pyparsing
    python-dateutil
    scikit-learn
    scipy
    six
    tqdm
  ];

  meta = with lib; {
    homepage = "https://github.com/abhirooptalasila/AutoSub";
    description = "generate video subtitles with offline speech recognition, based on Coqui STT";
    license = licenses.mit;
  };
}
