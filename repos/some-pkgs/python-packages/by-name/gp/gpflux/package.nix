{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
, protobuf3
, deprecated
, numpy
, scipy
, gpflow
, pytestCheckHook
, pytest-mock
, pytest-cov
, pytest-random-order
, matplotlib
, tqdm
}:
buildPythonPackage rec {
  pname = "GPflux";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-V/23Dos907zoLYSXRoUkXXIabpLOHyT+huvpOK0+5zc=";
  };
  postPatch = ''
    # sed -i 's/tensorflow>/${builtins.replaceStrings ["-"] ["_"] tensorflow.pname}>/' setup.py
  ''
  # One of our dependencies propagates protobuf4 and it works anyway
  +
  ''
    sed -i 's/"protobuf[^"]*"/"protobuf>=3.19.0"/' setup.py
  ''
  # Remove version constraint on tensorflow
  + ''
    sed -i '/tensorflow>/d' setup.py
  ''
  # Remove version constraint on tfp
  + ''
    sed -i '/tensorflow-probability>/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability
  ];

  propagatedBuildInputs = [
    # protobuf3
    gpflow
    deprecated
    numpy
    scipy
  ];
  checkInputs = [
    tqdm
    matplotlib
    pytestCheckHook
    pytest-mock
    pytest-cov
    pytest-random-order
  ];

  disabledTestPaths = [
    "tests/test_notebooks.py"
  ];

  pytestFlagsArray = [
    "--exitfirst"
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

    # Something about "TrackableLayer" and gpflux simply being permanently broken for almost all versions of tf and tfp
    # broken = lib.versionAtLeast tensorflow.version "2.10" || lib.versionAtLeast tensorflow-probability.version "0.19.0";
  };
}

