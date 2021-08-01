{ lib
, python3Packages
, fetchFromGitHub
, xvfb-run
, scrot
}:

python3Packages.buildPythonPackage rec {
  pname = "PyScreeze";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pyscreeze";
    rev = "0446e87235e0079f591f0c49ece7d487dedc2f9a";
    sha256 = "1dhcmvdlsv7y3mggmk7g4jsdwkjagfw7slmg3zln64f1ksvkfv7g";
  };

  nativeBuildInputs = [ xvfb-run ];
  propagatedBuildInputs = with python3Packages; [
    pillow
  ];
  checkInputs = with python3Packages; [ pytest xlib scrot ];

  doCheck = true;
  checkPhase = ''
    xvfb-run -s '-screen 0 800x600x24' \
      pytest
  '';

  meta = with lib; {
    description = "Simple, cross-platform screenshot module for Python 2 and 3";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
