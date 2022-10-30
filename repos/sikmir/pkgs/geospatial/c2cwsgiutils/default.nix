{ lib, fetchFromGitHub, python3Packages, pipfile }:

python3Packages.buildPythonPackage rec {
  pname = "c2cwsgiutils";
  version = "5.1.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "c2cwsgiutils";
    rev = version;
    hash = "sha256-lPE21SLMgfnNu0qiM3e2qz6zJJ7u5YaNkqOSNTF1FVg=";
  };

  propagatedBuildInputs = with python3Packages; [
    boltons
    lxml
    netifaces
    pipfile
    psycopg2
    pyramid
    requests
    setuptools
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
