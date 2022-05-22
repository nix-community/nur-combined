{
  lib
, buildPythonPackage
, fetchFromGitHub
, pypemicro
, setuptools
, setuptools-scm
, setuptools-scm-git-archive
}:
buildPythonPackage rec {
  version = "1.1.3";
  pname = "pyocd-pemicro";
  doCheck = false;
  src = fetchFromGitHub {
    owner = "pyocd";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-MqT+cT+enV8JCNysSK+kIFruNehcR1cBGnEZYSA9z7Q=";
  };

  buildInputs = [
    setuptools
    setuptools-scm
    setuptools-scm-git-archive
  ];

  propagatedBuildInputs = [
    pypemicro
  ];
}