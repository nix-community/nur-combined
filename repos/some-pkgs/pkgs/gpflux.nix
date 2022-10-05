{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-y9GJIk0ZpyvJfcnLGCm4Ofdqkfmy1ko6TYqM8l9A1Fg=";
  };
  postPatch = ''
    # sed -i 's/tensorflow>/${builtins.replaceStrings ["-"] ["_"] tensorflow.pname}>/' setup.py
    sed -i '/tensorflow>/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability
  ];

  propagatedBuildInputs = [
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
    broken = lib.versionAtLeast tensorflow.version "2.10";
  };
}
