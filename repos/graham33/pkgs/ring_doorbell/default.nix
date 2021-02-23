{ lib
, buildPythonPackage
, fetchPypi
, isPy3k
, pytestCheckHook
, pytz
, requests
, requests-mock
, requests_oauthlib
}:

buildPythonPackage rec {
  pname = "ring_doorbell";
  version = "0.6.2";
  disabled = !isPy3k;

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
    pytestCheckHook
    requests-mock
  ];

  pythonImportsCheck = [ "ring_doorbell" ];

  meta = with lib; {
    homepage = "https://github.com/tchellomello/python-ring-doorbell";
    description = "A Python library to communicate with Ring Door Bell (https://ring.com/)";
    license = licenses.lgpl2;
    #maintainers = with maintainers; [ graham33 ];
  };
}
