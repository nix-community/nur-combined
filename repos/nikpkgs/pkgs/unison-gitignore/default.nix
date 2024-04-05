{ pkgs, lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "unison-gitignore";
  version = "1.0.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-obhDaGWtnLXyIoGfH5JTdx6nk2jRacVpOhgCGY0Prnk=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools-scm
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pathspec
  ];

  meta = with lib; {
    broken      = true;
    description = "A gitignore-aware wrapper around Unison" ;
    homepage    = "https://github.com/lime-green/unison-gitignore";
    license     = licenses.mit;
  };
}

