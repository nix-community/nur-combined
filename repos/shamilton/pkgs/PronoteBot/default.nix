{ lib
, buildPythonPackage
, fetchFromGitHub 
, click
, geckodriver
, pyautogui
, pybase64
, selenium
, wget
}:

buildPythonPackage rec {
  pname = "PronoteBot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "PronoteBot";
    rev = "6a32db8e1ae6c222a18cfa2074d2a591423f2ee5";
    sha256 = "196jf20afci5pmz5p233ma676z9xdb7i2k97vfs89brbw99k9f45";
  };

  # src = ./src.tar.gz;

  propagatedBuildInputs = [
    click
    geckodriver
    pyautogui
    pybase64
    selenium
    wget
  ];

  doCheck = false;

  meta = with lib; {
    description = "Pronote bot to open pronote or to open the physics and chemistry book at a specified page";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
