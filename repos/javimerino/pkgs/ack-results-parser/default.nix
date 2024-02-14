{ lib
, pkgs
, python-hwinfo
}:

pkgs.python3Packages.buildPythonApplication {
  pname = "ack-results-parser";
  # Upstream does not do versions
  version = "0.1.0-a09a9024e19e";
  # Temporarily get my python3 conversion branch
  src = pkgs.fetchFromGitHub {
    owner = "JaviMerino";
    repo = "ack-results-parser";
    rev = "a09a9024e19e46eff8d9a35941bdc7a984a3e501";
    hash = "sha256-CpcKhyvbDSkr6ZV/qtUNeiHBSFKKYqt2prCDZ+eMTik=";
  };
  # nose tests have not been converted to python3
  doCheck = false;
  propagatedBuildInputs = with pkgs.python3Packages; [
    jira
    pymongo
    python-hwinfo
  ];

  meta = with lib; {
    description = "Tool for parsing the output of an ACK run";
    homepage = "https://github.com/xenserver/ack-results-parser/";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.unlicense ];
    platforms = platforms.all;
  };
}
