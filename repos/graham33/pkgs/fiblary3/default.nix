{ lib
, buildPythonPackage
, isPy3k
, fetchFromGitHub
, fixtures
, jsonpatch
, mock
, netaddr
, prettytable
, pytestCheckHook
, python-dateutil
, requests
, requests-mock
, six
, sphinx
, testtools
}:

buildPythonPackage rec {
  pname = "fiblary3";
  version = "0.1.8";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    # TODO: fix
    owner = "graham33";
    repo = "fiblary";
    rev = "bda5e5434adf446e8659223816ec7cc9452fa393";
    sha256 = "1fww6ackarn4sdlwwkk22x3lcbh1m1rjx9yl4ksbvakhh1jfycii";
  };

  nativeBuildInputs = [
    sphinx
  ];

  propagatedBuildInputs = [
    jsonpatch
    netaddr
    prettytable
    python-dateutil
    requests
    six
  ];

  checkInputs = [
    fixtures
    mock
    pytestCheckHook
    requests-mock
    testtools
  ];

  pythonImportsCheck = [ "fiblary3" ];

  meta = with lib; {
    homepage = "https://github.com/pbalogh77/fiblary";
    description = "Fibaro Home Center API Python Library";
    license = licenses.asl20;
    #maintainers = with maintainers; [ graham33 ];
  };
}
