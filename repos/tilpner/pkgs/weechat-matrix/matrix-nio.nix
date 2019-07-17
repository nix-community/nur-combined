{ buildPythonPackage, fetchFromGitHub, git,
  attrs, future, peewee, h11, h2, atomicwrites, pycryptodome, sphinx, Logbook, jsonschema,
  python-olm, unpaddedbase64 }:

buildPythonPackage {
  pname = "nio";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = "587d2cc814af4bc9c7a8bc8380a5022afc39290b";
    sha256 = "09kcqv5wjvxnx3ligql6k7h5rshsim97y356c9k01d9hpv1lbccb";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'python-olm>=3.1.0' ""
  '';


  nativeBuildInputs = [
    git
  ];

  propagatedBuildInputs = [
    attrs
    future
    peewee
    h11
    h2
    atomicwrites
    pycryptodome
    sphinx
    Logbook
    jsonschema
    python-olm
    unpaddedbase64
  ];

  doCheck = false;
}
