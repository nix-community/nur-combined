{ lib
, buildPythonApplication
, fetchFromGitLab
, requests
, lxml
, cssselect
, curlify
, poetry-core
}:

buildPythonApplication rec {
  pname = "pricehist";
  version = "1.4.6";
  format = "pyproject";

  src = fetchFromGitLab {
    owner = "chrisberkhout";
    repo = "pricehist";
    rev = version;
    hash = "sha256-sCad5lQqkW6mZlI/0+DFSj9FleCOyBLJG264RrtqByA=";
  };

  propagatedBuildInputs = [
    requests
    lxml
    cssselect
    curlify
    poetry-core
  ];

  meta = with lib; {
    description = "A command-line tool for fetching and formatting historical price data, with support for multiple data sources and output formats";
    homepage = "https://github.com/chrisberkhout/pricehist";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
