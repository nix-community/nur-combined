{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "about-time";
  version = "unstable-2022-12-20";
  project = "setuptools";

  # Tests are on GitHub
  src = fetchFromGitHub {
    owner = "rsalmei";
    repo = "about-time";
    rev = "bcabddd4c864d58b272a1d69b321ca9184ba45ac";
    sha256 = "sha256-ewtXqBWXpf+fEj/ljvup6dUBKejaiZiAZ728jRRMpj8=";
  };

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "about_time" ];

  meta = with lib; {
    description = "A cool helper for tracking time and throughput of code blocks, with beautiful human friendly renditions";
    homepage = "https://github.com/rsalmei/about-time";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
