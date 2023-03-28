{ lib
, buildPythonPackage
, fetchFromGitHub
, about-time
, grapheme
, click
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "alive-progress";
  version = "unstable-2023-01-01";
  project = "setuptools";

  # Tests are on GitHub
  src = fetchFromGitHub {
    owner = "rsalmei";
    repo = "alive-progress";
    rev = "e38a5f8dda3ec36e26d17bcb5dc93ab03bb9f29e";
    sha256 = "sha256-6UTg46XS9hEeB7/vuoA/8aFPl/5l5sNrlu3r2GClxXA=";
  };

  propagatedBuildInputs = [
    about-time
    grapheme
  ];

  checkInputs = [
    click
    pytestCheckHook
  ];

  pythonImportsCheck = [ "alive_progress" ];

  meta = with lib; {
    description = "A new kind of Progress Bar, with real-time throughput, ETA, and very cool animations";
    homepage = "https://github.com/rsalmei/alive-progress";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
