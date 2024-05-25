{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "wptools";
  version = "0.4.17-unstable-2022-02-22";

  src = fetchFromGitHub {
    owner = "siznax";
    repo = "wptools";
    rev = "a98a544f206a62c9f04fd34c0805825a8d531936";
    hash = "sha256-l1sCEhveK9fefZY6tL/kh2bOcq4ids4HZu6pXvn17AA=";
  };

  propagatedBuildInputs = with python3Packages; [
    certifi
    html2text
    lxml
    requests
  ];

  doCheck = false;

  meta = {
    description = "Wikipedia tools (for Humans)";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
