{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability_8_0
, gpflux
, gpflow
, greenlet
, pytest
}:

buildPythonPackage rec {
  pname = "trieste";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "a160d2400a2dc092cac599554d32217840c06e3d";
    sha256 = "sha256-5PJ3OL0LR9EDVLlIQTYhG8yZko9VaDfzuncP5Oc7TiE=";
  };
  postPatch = ''
    sed -i 's/gpflow==2.2.\\*/gpflow>=2.2/' setup.py
    sed -i '/tensorflow>=2.4/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability_8_0
  ];
  propagatedBuildInputs = [
    gpflux
    gpflow
    greenlet
  ];
  checkInputs = [
    pytest
  ];
  pythonImportsCheck = [ "trieste" ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "A Bayesian optimization toolbox built on TensorFlow";
    homepage = "https://secondmind-labs.github.io/trieste/";
    platforms = lib.platforms.unix;
  };
}
