{ buildPythonPackage, fetchFromGitHub, git,
  attrs, future, peewee, h11, h2, atomicwrites, pycrypto, sphinx, Logbook, jsonschema,
  python-olm, unpaddedbase64 }:

buildPythonPackage {
  pname = "nio";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = "53df97444b148ee9f52741c56bfc5c49f98e6397";
    sha256 = "040wfnl138q5jl1pc3szliany6fvr19whni8nb0yz8dwrgdyq4b8";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '@ git+https://github.com/poljar/python-olm.git@master#egg=python-olm-0' ""
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
    pycrypto
    sphinx
    Logbook
    jsonschema
    python-olm
    unpaddedbase64
  ];

  doCheck = false;
}
