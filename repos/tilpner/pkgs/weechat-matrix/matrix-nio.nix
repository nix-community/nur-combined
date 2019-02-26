{ buildPythonPackage, fetchFromGitHub, git,
  attrs, future, peewee, h11, h2, atomicwrites, pycrypto, sphinx, Logbook, jsonschema,
  python-olm, unpaddedbase64 }:

buildPythonPackage {
  pname = "nio";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = "62e2c8af2bedc59f53be812b0ba6e4cd0d8a91c6";
    sha256 = "0iyhq7lfizn6py4vjvckdibhg0ggfv14bm4nrn350mpk928pxl93";
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
