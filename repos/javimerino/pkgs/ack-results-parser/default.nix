{ fetchFromGitHub
, lib
, python-hwinfo
, python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "ack-results-parser";
  # Upstream does not do versions
  version = "0.1.0-20240611-af271293fbab";
  src = fetchFromGitHub {
    owner = "xenserver";
    repo = "ack-results-parser";
    rev = "af271293fbabbaacc487a0d4794ac6008948243f";
    hash = "sha256-TVVIdwq+BRiB/Rhpdm9I3410MaH7BY900S/h4UC6Yc0=";
  };
  format = "setuptools";

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
