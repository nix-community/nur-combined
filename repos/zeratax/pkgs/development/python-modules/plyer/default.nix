{ lib
, buildPythonPackage
, python3Packages
, fetchPypi
}:

buildPythonPackage rec {
  pname = "plyer";
  version = "2.0.0";

  src = fetchPypi {
    inherit version pname;
    extension = "tar.gz";
    sha256 = "8de38b17bc438df36eedeacd546cf05303ab871855af0669fc4e8df51f2adf94";
  };

  propagatedBuildInputs = with python3Packages; [
    keyring
  ];

  doCheck = false;

  meta = with lib; {
    description = "Platform-independent wrapper for platform-dependent APIs.";
    homepage = "https://plyer.readthedocs.org/en/latest/";
    license = licenses.mit;
  };
}
