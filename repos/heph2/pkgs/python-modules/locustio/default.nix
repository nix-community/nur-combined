{ lib
, buildPythonPackage
, python3Packages
, fetchFromGitHub
, roundrobin
}:

buildPythonPackage rec {
  pname = "locustio";
  version = "2.14.1";

  src = fetchFromGitHub {
    owner = "locustio";
    repo = "locust";
    rev = version;
    hash = "sha256-CxWZIBRHMr4zBAPzca+sVu3BmKP2F/DvUl+PFLYsHWI";
  };

  patchPhase = ''
     echo 'version = "${version}"' > locust/_version.py
  '';

  checkInputs = with python3Packages; [ tox tomli ];

  checkPhase = ''
    tox -e mypy
  '';

  propagatedBuildInputs = with python3Packages; [
    requests
    flask-basicauth
    flask-cors
    msgpack
    gevent
    pyzmq
    roundrobin
    geventhttpclient
    psutil
    typing-extensions
    configargparse
    setuptools
  ];

  meta = with lib; {
    description = "A load testing tool";
    homepage = "https://locust.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ shyim ];
  };
}
