{ lib, buildPythonPackage, fetchPypi, setuptools, pytz, sqlalchemy-utils
, tzlocal, click, fetchpatch }:

buildPythonPackage rec {
  pname = "piecash";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-iWOfBmHUkiQng/OcjRR+pFwyHcQRH5PsopefBw9fF20=";
  };

  propagatedBuildInputs = [ setuptools pytz sqlalchemy-utils tzlocal click ];

  patches = [
    (fetchpatch {
      url = "https://github.com/sdementen/piecash/pull/193.patch";
      sha256 = "sha256-sSsln8c3XOEnLFlE8TlVRGOoVnvH8hSLNaYNQ70L+So=";
    })
  ];
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/sdementen/piecash";
    description = "Pythonic interface to GnuCash SQL documents";
    license = licenses.mit;
    broken = true;
  };
}
