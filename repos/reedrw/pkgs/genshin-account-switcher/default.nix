{ lib, python3Packages, fetchFromGitHub }:
with python3Packages;

buildPythonPackage rec {
  pname = "genshin-account-switcher";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "atomicptr";
    repo = "genshin-account-switcher";
    rev = "e4fb83abc7697469a04ab1b8fb73425d681b15b0";
    hash = "sha256-JMLj3/znMSHy/j8r+jmiLvMD55DdcDTcS74LSkSyG+c=";
  };

  propagatedBuildInputs = [
    appdirs
    tkinter
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/atomicptr/genshin-account-switcher";
    description = "Simple account switcher for Genshin Impact on Linux. ";
    license = licenses.gpl3Only;
  };
}
