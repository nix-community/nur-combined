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
    rev = "cad9f575332623ea5eb809af409c22be23d9598c";
    sha256 = "0v0mlcp4sja5nqqxbvfm3k3vqlljzvdljhd7jja91icx9prnc14n";
  };

  propagatedBuildInputs = with python3Packages; [ pexpect ];
  doCheck = false;

  meta = with lib; {
    description = "Automatic reconnect script for gnirehtet";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
