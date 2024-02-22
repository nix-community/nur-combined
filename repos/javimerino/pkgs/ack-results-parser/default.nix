{ fetchFromGitHub
, lib
, python-hwinfo
, python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "ack-results-parser";
  # Upstream does not do versions
  version = "0.1.0-20240220-32e04ac47a00";
  # Temporarily get my python3 conversion branch
  src = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "ack-results-parser";
    rev = "32e04ac47a001db5214ba5941a223fb47886117b";
    hash = "sha256-N+DMYOKRul+pXsl1B4J0la4ggaqwUevhssFg61iaQj0=";
  };
  # nose tests have not been converted to python3
  doCheck = false;
  propagatedBuildInputs = with python3Packages; [
    jira
    pymongo
    python-hwinfo
  ];

  meta = with lib; {
    description = "Tool for parsing the output of an ACK run";
    homepage = "https://github.com/xenserver/ack-results-parser/";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.unlicense ];
  };
}
