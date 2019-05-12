{ buildPythonPackage, fetchFromGitHub, git,
  attrs, future, peewee, h11, h2, atomicwrites, pycryptodome, sphinx, Logbook, jsonschema,
  python-olm, unpaddedbase64 }:

buildPythonPackage {
  pname = "nio";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = "c574fb247566f6a33e05c090e7e8444f7dc6d336";
    sha256 = "13mrw9lvhzf4ykdagvw38k1p682b244ap9vvrcmjxrylz6d686li";
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
