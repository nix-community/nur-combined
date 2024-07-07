{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "commix";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "commixproject";
    repo = "commix";
    rev = "v${version}";
    sha256 = "sha256-pqfb0CkWTPq6B8T7nn25lWuEQFRRziCDWYm5a1S3mIY=";
  };

  propagatedBuildInputs = with python3Packages; [ tornado python-daemon ];

  doCheck = true;

  meta = with lib; {
    description = "Automated All-in-One OS Command Injection Exploitation Tool";
    license = licenses.gpl3Only;
    homepage = "https://commixproject.com/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
