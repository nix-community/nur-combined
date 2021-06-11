{ lib
, buildPythonApplication
, fetchFromGitHub
, pexpect
}:

buildPythonApplication rec {
  pname = "AutoGnirehtet";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "AutoGnirehtet";
    rev = "557eb2186011e92f06a45283b067b49ab3f433f0";
    sha256 = "0nr62ylmk379h4dpg5chz1zpa6pngnb1m7l7sf3d6mnc9i4g5bmm";
  };
  propagatedBuildInputs = [ pexpect ];
  doCheck = false;

  meta = with lib; {
    description = "Automatic reconnect script for gnirehtet";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
