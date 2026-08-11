{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "webvtt-py";
  version = "0.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "glut23";
    repo = "webvtt-py";
    rev = version;
    hash = "sha256-rsxhZ/O/XAiiQZqdsAfCBg+cdP8Hn56EPbZARkKamdA=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "webvtt" ];

  meta = with lib; {
    description = "Read, write, convert and segment WebVTT caption files in Python";
    homepage = "https://github.com/glut23/webvtt-py";
    changelog = "https://github.com/glut23/webvtt-py/blob/${src.rev}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
