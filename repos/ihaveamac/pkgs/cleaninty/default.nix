{ lib, fetchFromGitHub, buildPythonApplication, cryptography, pycurl, defusedxml }:

buildPythonApplication rec {
  name = "cleaninty";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "luigoalma";
    repo = name;
    rev = "v0.1.3";
    sha256 = "sha256-QVttOy3WPFZXvbNaJUhFSsEWwPDZgkGuDBR7zxlS+w8=";
  };

  propagatedBuildInputs = [ 
    cryptography
    pycurl
    defusedxml
  ];

  meta = with lib; {
    description = "Perform some Nintendo console client to server operations";
    homepage = "https://github.com/luigoalma/cleaninty";
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "cleaninty";
  };
}
