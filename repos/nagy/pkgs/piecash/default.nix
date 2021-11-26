{ lib, buildPythonPackage, fetchPypi, setuptools, pytz, sqlalchemy-utils, tzlocal, click  }:

buildPythonPackage rec {
  pname = "piecash";
  version = "1.1.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "04jnp8mxxznnjnbj68qzjk8yj1f5pk9rzm9f4p172fhk6lkij8qc";
  };

  propagatedBuildInputs = [ setuptools pytz sqlalchemy-utils tzlocal click ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/sdementen/piecash";
    description = "Pythonic interface to GnuCash SQL documents";
    license = licenses.mit;
  };
}
