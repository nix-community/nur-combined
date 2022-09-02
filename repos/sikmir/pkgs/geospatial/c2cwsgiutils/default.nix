{ lib, fetchFromGitHub, python3Packages, pipfile }:

python3Packages.buildPythonPackage rec {
  pname = "c2cwsgiutils";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "c2cwsgiutils";
    rev = version;
    hash = "sha256-O+uh+9NurjnohCbpxJxrpvUUkb1gPHsqvG7+F4WNjQg=";
  };

  propagatedBuildInputs = with python3Packages; [
    boltons
    lxml
    netifaces
    pipfile
    psycopg2
    pyramid
    requests
  ];

  doCheck = false;
  pythonImportsCheck = [ "c2cwsgiutils" ];

  meta = with lib; {
    description = "Common utilities for Camptocamp WSGI applications";
    inherit (src.meta) homepage;
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
  };
}
