{ lib, fetchFromGitHub, python3Packages, bson }:

python3Packages.buildPythonApplication rec {
  pname = "apibackuper";
  version = "2020-11-03";

  src = fetchFromGitHub {
    owner = "ruarxive";
    repo = pname;
    rev = "1ff139f688d59b899ff041ccc282e224110ddc76";
    hash = "sha256-BL17WmRV07UroVFw3fyTrQ6s0czEBpc8HRD7hUpqnAY=";
  };

  propagatedBuildInputs = with python3Packages; [ bson click lxml requests xmltodict ];

  doCheck = false;

  meta = with lib; {
    description = "Python library and cmd tool to backup API calls";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
