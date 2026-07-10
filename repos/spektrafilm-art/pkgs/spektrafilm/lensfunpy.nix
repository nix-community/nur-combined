{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  cython,
  numpy,
  pkg-config,
  lensfun,
}:

buildPythonPackage rec {
  pname = "lensfunpy";
  version = "1.18.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "letmaik";
    repo = "lensfunpy";
    rev = "v${version}";
    hash = "sha256-F3PZ5s8aDPXHwedlWp5qV8uusjGh8ODmg/duuCPJf7I=";
  };

  build-system = [
    setuptools
    cython
    numpy
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    lensfun
  ];

  dependencies = [
    numpy
  ];

  doCheck = false;

  pythonImportsCheck = [ "lensfunpy" ];

  meta = with lib; {
    description = "Python wrapper for the lensfun library";
    homepage = "https://github.com/letmaik/lensfunpy";
    license = licenses.mit;
  };
}
