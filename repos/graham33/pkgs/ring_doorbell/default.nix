{ lib
, buildPythonPackage
, fetchPypi
, isPy3k
, pytest
, pytz
, requests
, requests-mock
, requests_oauthlib
}:

buildPythonPackage rec {
  pname = "ring_doorbell";
  version = "0.7.0";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "1qnx9q9rzxhh0pygl3f9bg21b5zv7csv9h1w4zngdvsphbs0yiwg";
  };

  propagatedBuildInputs = [
    pytz
    requests
    requests_oauthlib
  ];

  checkInputs = [
    pytest
    requests-mock
  ];

  meta = with lib; {
    homepage = "https://github.com/tchellomello/python-ring-doorbell";
    description = "A Python library to communicate with Ring Door Bell (https://ring.com/)";
    license = licenses.lgpl2;
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
