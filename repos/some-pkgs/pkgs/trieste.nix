{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
, gpflux
, gpflow
, greenlet
, pytest
}:

buildPythonPackage rec {
  pname = "trieste";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-wNyhr/DJGIJ6zQtsRMS06elAoHXTCqQZoYPabzGWcW8=";
  };
  postPatch = ''
    sed -i 's/gpflow==2.2.\\*/gpflow>=2.2/' setup.py
    sed -i '/tensorflow>=2.4/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability
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
