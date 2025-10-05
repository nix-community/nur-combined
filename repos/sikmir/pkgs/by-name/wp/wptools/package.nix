{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "wptools";
  version = "0.4.17-unstable-2022-02-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "siznax";
    repo = "wptools";
    rev = "a98a544f206a62c9f04fd34c0805825a8d531936";
    hash = "sha256-l1sCEhveK9fefZY6tL/kh2bOcq4ids4HZu6pXvn17AA=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    html2text
    lxml
    requests
  ];

  doCheck = false;

  meta = {
    description = "Wikipedia tools (for Humans)";
    homepage = "https://github.com/siznax/wptools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
