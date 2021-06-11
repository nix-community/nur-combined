{ lib
, buildPythonPackage
, fetchPypi 
, pillow
, pyperclip
, python3-xlib
}:

buildPythonPackage rec {
  pname = "MouseInfo";
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1rznyzv6w9f8bfq2x5b0ik0dqyk5ghlhmkiw1998waq6hn4gnqic";
  };

  propagatedBuildInputs = [
    pillow
    pyperclip
    python3-xlib
  ];

  doCheck = false;

  meta = with lib; {
    longDescription = ''
      An application to display XY position and RGB color information for the
      pixel currently under the mouse. Works on Python 2 and 3.
    '';
    license = licenses.gpl3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
