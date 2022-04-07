{ lib
, python
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability_8_0
, numpy
, scipy
, deprecated
, typing-extensions
, tabulate
, multipledispatch
, setuptools
, wheel
, build
, keras
, jupytext
, pytest
, nbconvert
}:
buildPythonPackage rec {
  pname = "GPflow";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "GPflow";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YOZ1S25VED6RVsylPv8Gh8iWoj0OIyPhn+KIK560HiU=";
  };
  postPatch = ''
    sed -i '/tensorflow>=/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability_8_0
    jupytext
  ];
  propagatedBuildInputs = [
    keras
    numpy
    scipy
    deprecated
    typing-extensions
    tabulate
    multipledispatch
  ];
  nativeBuildInputs = [
    setuptools
    wheel
    build
  ];
  checkInputs = [
    pytest
    nbconvert
  ];
  pythonImportsCheck = [ "gpflow" ];

  doCheck = true;

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "Gaussian processes in TensorFlow";
    homepage = "https://www.gpflow.org/";
    platforms = lib.platforms.unix;
  };
}
