{
  lib,
  fetchFromGitHub,
  python3Packages,
  pipfile,
}:

python3Packages.buildPythonPackage rec {
  pname = "c2cwsgiutils";
  version = "5.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "c2cwsgiutils";
    tag = version;
    hash = "sha256-lPE21SLMgfnNu0qiM3e2qz6zJJ7u5YaNkqOSNTF1FVg=";
  };

  dependencies = with python3Packages; [
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

  meta = {
    description = "Common utilities for Camptocamp WSGI applications";
    homepage = "https://github.com/camptocamp/c2cwsgiutils";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
