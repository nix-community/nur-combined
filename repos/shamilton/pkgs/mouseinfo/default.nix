{ lib
, fetchFromGitHub
, python3Packages
, python3-xlib
}:

python3Packages.buildPythonApplication rec {
  pname = "MouseInfo";
  version = "2023-05-05";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "mouseinfo";
    rev = "23791fad3347efef405e1bbe65809a6394b1677d";
    sha256 = "sha256-A1RN6aczG1c0jb1sMalGmJoZ/A4I1sHunlVcfym7o0c=";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    pyperclip
    python3-xlib
    setuptools
  ];

  doCheck = false;

  meta = with lib; {
    description = "Displays XY position and RGB color under the mouse";
    homepage = "https://github.com/asweigart/mouseinfo";
    license = licenses.gpl3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
