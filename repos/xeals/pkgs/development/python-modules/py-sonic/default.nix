{ stdenv
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "py-sonic";
  version = "0.7.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0wh2phg8h02a6vlpqd0widd6g8ng142vzmk8hpyx0bnwn2i45sjc";
  };

  doCheck = false;

  meta = {
    homepage = "https://stuffivelearned.org/doku.php?id=programming:python:py-sonic";
    license = stdenv.lib.licenses.gpl3;
    description = "A python wrapper library for the Subsonic REST API";
  };
}
