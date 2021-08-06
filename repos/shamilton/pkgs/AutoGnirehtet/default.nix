{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "AutoGnirehtet";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "AutoGnirehtet";
    rev = "c176b5ec15b7c067ef228fbcce779a949f96a532";
    sha256 = "14d18439vnfl2vid8n15y4ijs5yyfvq5glif5shy9hqx4gn810cr";
  };

  propagatedBuildInputs = with python3Packages; [
    pexpect
    pure-python-adb
  ];
  doCheck = false;

  meta = with lib; {
    description = "Automatic reconnect script for gnirehtet";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
