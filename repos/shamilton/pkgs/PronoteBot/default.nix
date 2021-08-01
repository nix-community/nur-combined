{ lib
, python3Packages
, fetchFromGitHub 
, geckodriver
, pyautogui
}:

python3Packages.buildPythonPackage rec {
  pname = "PronoteBot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "PronoteBot";
    rev = "4033ba7c937f9fbdb50416ecb8bd030754392770";
    sha256 = "1lblqb98lmxw3n90zggy0hqx9zgml2gwbgpnyajqrnkj3p2grfjj";
  };

  propagatedBuildInputs = with python3Packages; [
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
