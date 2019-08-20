{ buildPythonPackage, fetchFromGitHub, git,
  attrs, future, peewee, h11, h2, atomicwrites, pycryptodome, sphinx, Logbook, jsonschema,
  python-olm, unpaddedbase64 }:

buildPythonPackage {
  pname = "nio";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = "cfe900cc55a1b6fb435ecf792d9d173aa16fa9b9";
    sha256 = "1nyaxmdd5wyr58nfk33sbihnm23dfznzbrvd7l76sd913cgnk9hk";
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
