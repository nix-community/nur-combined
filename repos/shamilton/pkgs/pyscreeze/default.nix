{ lib
, buildPythonPackage
, fetchFromGitHub
, pillow
, pytest
, xlib
, xvfb-run
, scrot
}:

buildPythonPackage rec {
  pname = "PyScreeze";
  version = "latest";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pyscreeze";
    rev = "0446e87235e0079f591f0c49ece7d487dedc2f9a";
    sha256 = "1dhcmvdlsv7y3mggmk7g4jsdwkjagfw7slmg3zln64f1ksvkfv7g";
  };

  nativeBuildInputs = [ xvfb-run ];
  propagatedBuildInputs = [
    pillow
  ];
  checkInputs = [ pytest xlib scrot ];

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
