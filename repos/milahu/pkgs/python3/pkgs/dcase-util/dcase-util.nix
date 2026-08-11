{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, nose
, numpy
, scipy
, matplotlib
, librosa
, six
, future
, soundfile
, pyyaml
, msgpack
, ujson
, requests
, tqdm
, pydot-ng
#, pafy
, youtube-dl
, validators
, pyparsing
, titlecase
, colorama
, python-magic
, markdown
, jinja2
}:

buildPythonPackage rec {
  pname = "dcase-util";
  version = "0.2.20";
  src = fetchFromGitHub {
    owner = "DCASE-REPO";
    repo = "dcase_util";
    rev = "v${version}";
    sha256 = "sha256-JOAoknGz0Y1lGLnrFn316qxvWYOYmCzAjBEOoJn+y80=";
  };
  nativeBuildInputs = [
    nose # nosetests
  ];

  # fixme: error: invalid command 'nosetests'
  doCheck = false;

  propagatedBuildInputs = [
    nose
    numpy
    scipy
    matplotlib
    librosa
    six
    future
    soundfile
    pyyaml
    msgpack
    ujson
    requests
    tqdm
    pydot-ng
    #pafy
    youtube-dl
    validators
    pyparsing
    titlecase
    colorama
    python-magic
    markdown
    jinja2
  ];
  checkInputs = [
    nose
  ];
  meta = with lib; {
    homepage = "https://github.com/DCASE-REPO/dcase_util";
    description = "A collection of utilities for Detection and Classification of Acoustic Scenes and Events";
    license = licenses.mit;
  };
}
