{ lib
, fetchFromGitHub
, python3Packages
, python3-xlib
}:

python3Packages.buildPythonApplication rec {
  pname = "MouseInfo";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "mouseinfo";
    rev = "a323c0e7253e01366f12d023cb5e481c5a08eb5c";
    sha256 = "0r6mngbapiccgpm8axbh8m9c5bv0chhf3r4700hddrgxrwyi3909";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    pyperclip
    python3-xlib
    setuptools
  ];

  # preBuild = ''
  #   export PYTHONPATH=$PYTHONPATH:${makePythonPath propagatedBuildInputs}
  # '';

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
