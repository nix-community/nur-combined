{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, packaging
, pluggy
, typing-extensions
}:

buildPythonPackage rec {
  pname = "ffmpegio";
  version = "0.11.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "python-ffmpegio";
    repo = "python-ffmpegio";
    rev = "v${version}";
    hash = "sha256-sxM69rvMk9Jy39mVnaPOJygrPyS7F8478b8fSt12hkw=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    packaging
    pluggy
    typing-extensions
  ];

  pythonImportsCheck = [ "ffmpegio" ];

  meta = with lib; {
    description = "Python package to read/write media files with FFmpeg";
    homepage = "https://github.com/python-ffmpegio/python-ffmpegio";
    changelog = "https://github.com/python-ffmpegio/python-ffmpegio/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
  };
}
