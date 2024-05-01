{ fetchFromGitHub
, lib
, python-hwinfo
, python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "ack-results-parser";
  # Upstream does not do versions
  version = "0.1.0-20240501-c40e521c42d0";
  # Temporarily get my dont_crash_on_no_driver branch
  src = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "ack-results-parser";
    rev = "c40e521c42d08797ed4821e31800d3afdf7ebef6";
    hash = "sha256-TVVIdwq+BRiB/Rhpdm9I3410MaH7BY900S/h4UC6Yc0=";
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
