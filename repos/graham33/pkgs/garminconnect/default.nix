{ lib
, buildPythonPackage
, fetchPypi
, requests
}:

buildPythonPackage rec {
  pname = "garminconnect";
  version = "0.1.18";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0pyczj7jza8pwzbgk8802ngqpmkivpdm83scrwplxasdbcsmqz5n";
  };

  propagatedBuildInputs = [
    requests
  ];

  # TODO: checks fail
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/cyberjunky/python-garminconnect";
    license = licenses.mit;
    description = "Python 3 API wrapper for Garmin Connect to get your statistics.";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
