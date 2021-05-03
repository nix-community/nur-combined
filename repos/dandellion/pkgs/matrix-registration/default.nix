{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "matrix-registration";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner  = "zeratax";
    repo   = "matrix-registration";
    rev    = "v0.7.0";
    sha256 = "1dlaf1828i814s9axqfa7jasb9g73pa13ngs6cglxnra3nwjzjfc";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    appdirs
    flask
    flask_sqlalchemy
    flask-cors
    flask-httpauth
    flask-limiter
    python-dateutil
    pyyaml
    requests
    waitress
    wtforms
  ];

  checkInputs = with python3Packages; [
    parameterized
    flake8
  ];

  meta = with lib; {
    description = "Token based matrix registration api";
    homepage    = "https://github.com/ZerataX/matrix-registration";
    license     = with licenses; mit;
  };
}
