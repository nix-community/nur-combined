{ lib, mpg123, aria2, libnotify, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "musicbox";
  version = "0.2.5.4";

  src = fetchFromGitHub {
    owner = "darknessomi";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-23hSAURL4x3zDaL+A0+xvnCVnyR0H/bmzNgi/6bFeJI=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    mpg123
    aria2
    libnotify
  ] ++
  (with python3Packages; [
    setuptools
    requests
    requests-cache
    pycryptodomex
    future
  ]);

  meta = with lib; {
    homepage = "https://github.com/darknessomi/musicbox";
    description = "网易云音乐命令行版本";
    license = licenses.mit;
  };
}
