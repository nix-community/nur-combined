{ lib
, buildPythonPackage
, fetchFromGitHub
, flask
, webtest
, blinker
}:

buildPythonPackage rec {
  pname = "flask-webtest";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "aromanovich";
    repo = "flask-webtest";
    rev = "${version}";
    sha256 = "sha256-EQ5qjvzuFRCQTMJ5CzHu4nB+hsJ39iiMcmfPWIIoWF8=";
  };

  propagatedBuildInputs = [
    flask
    webtest
    blinker
  ];

  # tests expect availability to a sql server?
  doCheck = false;

  pythonImportsCheck = [ "flask_webtest" ];

  meta = with lib; {
    description = "Utilities for testing Flask applications with WebTest";
    homepage = "https://github.com/aromanovich/flask-webtest";
    license = licenses.bsd3;
    maintainers = with maintainers; [ imsofi ];
  };
}
