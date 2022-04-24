{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability_8_0
, deprecated
, numpy
, scipy
, gpflow
, pytest
, nbconvert
, jupytext
, matplotlib
}:
buildPythonPackage rec {
  pname = "GPflux";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "744943768bc5ab79027adad9f04bd61a7b2d42a8";
    sha256 = "sha256-rrlx/D9S5ZjFUh8ltQYZv688GAkgFwq2lkPHi2b87+o=";
  };
  postPatch = ''
    # sed -i 's/tensorflow>/${builtins.replaceStrings ["-"] ["_"] tensorflow.pname}>/' setup.py
    sed -i '/tensorflow>/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability_8_0
    # jupytext
  ];

  propagatedBuildInputs = [
    gpflow
    deprecated
    numpy
    scipy
  ];
  checkInputs = [
    pytest
    # nbconvert
    # matplotlib
  ];

  disabledTestPaths = [
    "tests/test_notebooks.py"
  ];

  pythonImportsCheck = [
    "gpflux"
    "gpflux.layers"
  ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "Deep Gaussian processes built on top of TensorFlow/Keras and GPflow";
    homepage = "https://secondmind-labs.github.io/GPflux/";
    platforms = lib.platforms.unix;
  };
}
