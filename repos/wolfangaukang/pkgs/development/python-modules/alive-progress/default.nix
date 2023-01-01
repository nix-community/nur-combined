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
  version = "unstable-2022-12-22";
  project = "setuptools";

  # Tests are on GitHub
  src = fetchFromGitHub {
    owner = "rsalmei";
    repo = "alive-progress";
    rev = "5eb8390ed09256a28cb79c7ea8a0ba9660015a5c";
    sha256 = "sha256-unOTBsClPdyUGzu32CSQFkfWucz3tEdLURTglCRSbyw=";
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
