{ fetchFromGitHub
, lib
, python-hwinfo
, python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "ack-results-parser";
  # Upstream does not do versions
  version = "0.1.0-20240509-c327db2a7288";
  # Temporarily get my dont_crash_on_no_driver branch
  src = fetchFromGitHub {
    owner = "xenserver";
    repo = "ack-results-parser";
    rev = "c327db2a728898db7674b3ae3daf5ef27b5f2638";
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
