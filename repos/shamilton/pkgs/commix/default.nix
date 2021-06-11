{ lib
, buildPythonApplication
, fetchFromGitHub
, python3Packages
}:

buildPythonApplication rec {
  pname = "commix";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "commixproject";
    repo = "commix";
    rev = "v${version}";
    sha256 = "0dnjwvqskyk04sv296lfvwyiahdqfq5h9klmp8lr8lp8fg329afq";
  };

  propagatedBuildInputs = with python3Packages; [ tornado_4 python-daemon ];

  doCheck = true;

  meta = with lib; {
    description = "Automated All-in-One OS Command Injection Exploitation Tool";
    license = licenses.gpl3Only;
    homepage = "https://commixproject.com/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
