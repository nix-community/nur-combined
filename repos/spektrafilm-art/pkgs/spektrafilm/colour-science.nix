# Disclaimer: Some Claude Opus 4.6 was used to write this
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  hatchling,
  numpy,
}:

buildPythonPackage rec {
  pname = "colour-science";
  version = "0.4.7";
  pyproject = true;
  pythonRuntimeDepsCheck = false;

  src = fetchFromGitHub {
    owner = "colour-science";
    repo = "colour";
    rev = "a3bfe349685f528100672e5c8ca2dfeeef64a273";
    hash = "sha256-yu0mmXnCZD1gEuTeo31mRjl+CaMdnaDlltIHf2v57pU=";
  };

  dependencies = [
    numpy
  ];

  build-system = [
    setuptools
    setuptools-scm
    hatchling
  ];

  meta = with lib; {
    description = "Colour Science for Python";
    homepage = "https://www.colour-science.org/";
  };
}
