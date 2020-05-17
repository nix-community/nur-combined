{ lib
, buildPythonPackage
, fetchPypi
, setuptools_scm
, pytest
, six
}:

buildPythonPackage rec {
  pname = "testinfra";
  version = "3.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0w78nw5r2hrv1ig7qdwkj9vzqhz2a7kk2x0pbqxyihhkxqgzdssw";
  };

  buildInputs = [ setuptools_scm ];

  patches = [
    ./fix-service-on-nixos.patch
    ./add-systemd-user-services.patch
  ];

  propagatedBuildInputs = [ pytest six ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://pypi.org/project/testinfra/";
    description = "Test your infrastructures";
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
