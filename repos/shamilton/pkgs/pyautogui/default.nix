{ lib
, buildPythonPackage
, fetchPypi
, mouseinfo
, pygetwindow
, pymsgbox
, pyscreeze
, python3-xlib
, pytweening
, pyrect
}:

buildPythonPackage rec {
  pname = "PyAutoGUI";
  version = "0.9.52";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1j7cb0xx8l3frvl5ddwlld7i6r79rv3i1l28igwwvjwbh5mwp1m4";
  };

  propagatedBuildInputs = [
    pyrect
    mouseinfo
    pygetwindow
    pymsgbox
    pyscreeze
    python3-xlib
    pytweening
  ];

  doCheck = false;

  meta = with lib; {
    longDescription = ''A cross-platform GUI automation Python module for
    human beings. Used to programmatically control the mouse & keyboard.'';
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
