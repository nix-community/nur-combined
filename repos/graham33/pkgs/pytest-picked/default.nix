{ lib
, buildPythonPackage
, fetchPypi
, pytest
}:

buildPythonPackage rec {
  pname = "pytest-picked";
  version = "0.4.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4ex67l0s06kfZ2/Qr9diCibAzMIeYEFSu8UTf0MObAA=";
  };

  propagatedBuildInputs = [
    pytest
  ];

  meta = with lib; {
    homepage = "https://github.com/anapaulagomes/pytest-picked";
    license = licenses.mit;
    description = "Run the tests related to the changed files";
    maintainers = with maintainers; [ graham33 ];
  };
}
