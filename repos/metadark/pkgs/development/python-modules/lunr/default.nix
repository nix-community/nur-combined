{ lib
, buildPythonPackage
, fetchFromGitHub
, future
, nltk
, six
, mock
, nodejs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "lunr.py";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "yeraydiazdiaz";
    repo = pname;
    rev = version;
    sha256 = "1r5f242iw4yja6c2kybrym61gmrq2j0zv7xf6378asjpqp2lbc33";
  };

  propagatedBuildInputs = [
    future
    nltk # optional? LANGUAGE_SUPPORT
    six
  ];

  preCheck = ''
    export PYTHONPATH=.:$PYTHONPATH
  '';

  doCheck = false; # tests are hard right now :(
  checkInputs = [
    mock
    nodejs # No such file or directory: 'node'?
    pytestCheckHook
  ];

  meta = with lib; {
    description = "A Python implementation of Lunr.js";
    homepage = "https://github.com/yeraydiazdiaz/lunr.py";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
