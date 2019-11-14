{ buildPythonPackage
, fetchPypi
, flask
, lib
}:

buildPythonPackage rec {
  version = "3.3.0";
  pname   = "Flask-HTTPAuth";
  name    = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1fb1kr1iw6inkwfv160rpjx54vv1q9b90psdyyghyy1f6dhvgy3f";
  };

  propagatedBuildInputs = [ flask ];
}
