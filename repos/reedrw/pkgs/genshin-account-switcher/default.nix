{ lib, python3Packages, fetchFromGitHub }:
with python3Packages;

buildPythonPackage rec {
  pname = "genshin-account-switcher";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "atomicptr";
    repo = "genshin-account-switcher";
    rev = "c9c19b917d41b874163ef4409bb728ee70f279f2";
    hash = "sha256-X4wwreY/7oXQ3OocYxQlhXqCJWDXtR57OD+wBYFg4gA=";
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
