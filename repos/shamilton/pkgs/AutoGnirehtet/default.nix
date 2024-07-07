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
    rev = "ab3ccf4a20617e583a11caf8d5fc2a835981c7d7";
    sha256 = "0rqldql5lcagrp09rmwydnzczrwvn4wscjw4iw4kip1jqwmcym77";
  };

  propagatedBuildInputs = with python3Packages; [
    pexpect
    pure-python-adb
  ];
  doCheck = false;

  meta = with lib; {
    description = "Automatic reconnect script for gnirehtet";
    homepage = "https://github.com/SCOTT-HAMILTON/AutoGnirehtet";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
