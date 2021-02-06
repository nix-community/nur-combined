{ lib
, buildPythonPackage
, fetchPypi
, pytest
, pytz
, requests
, requests-mock
, requests_oauthlib
}:

buildPythonPackage rec {
  pname = "ring_doorbell";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0q35sji2f4lphlr0hdpzazfbi6rrnyadh1k5q9abicr759r3gmgv";
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
    license = licenses.lgpl2;
    description = "A Python library to communicate with Ring Door Bell (https://ring.com/)";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
