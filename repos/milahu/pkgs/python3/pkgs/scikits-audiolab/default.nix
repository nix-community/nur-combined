/*
  TODO macos
  INFO: CoreAudioInfo:
  /build/source/audiolab/soundio/setup.py:31: UserWarning: CoreAudio not found - CoreAudio backend not build
    warnings.warn("CoreAudio not found - CoreAudio backend not build")
*/

{ lib
, python3
, fetchFromGitHub
, libsndfile
, alsa-lib
}:

python3.pkgs.buildPythonApplication rec {
  pname = "scikits-audiolab";
  version = "0.11.3";
  pyproject = true;

  src = fetchFromGitHub {
    /*
    owner = "cournape";
    repo = "audiolab";
    rev = version;
    hash = "sha256-WuTQAL5mvcSHswMiBopqszYjMqZgBjf4uv85lLVu4os=";
    */
    # make it work with python3
    # https://github.com/cournape/audiolab/issues/24
    # https://github.com/cournape/audiolab/pull/37
    # https://github.com/milahu/scikits-audiolab
    owner = "milahu";
    repo = "scikits-audiolab";
    rev = version;
    hash = "sha256-H8Z8138FE0L/xyuvrNff++Cs5c6qm9wC+7x4XrWNVjg=";
  };

  patches = [
    ./use-nix-input-paths.patch
  ];

  buildInputs = [
    libsndfile
    alsa-lib # libasound
  ];

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
    cython
  ];

  checkInputs = with python3.pkgs; [
    pytest
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
  ];

  pythonImportsCheck = [ "scikits.audiolab" ];

  meta = with lib; {
    description = "A python package for reading/writing audio files from numpy array";
    homepage = "https://github.com/cournape/audiolab";
    changelog = "https://github.com/cournape/audiolab/blob/${src.rev}/Changelog";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
  };
}
