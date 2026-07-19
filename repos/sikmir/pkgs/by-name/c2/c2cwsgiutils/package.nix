{
  lib,
  fetchFromGitHub,
  python3Packages,
  pipfile,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "c2cwsgiutils";
  version = "6.1.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "c2cwsgiutils";
    tag = finalAttrs.version;
    hash = "sha256-Ca3GCIavXqaimlmboeSHmEeZotQMtgoYXwFbR/ulR1M=";
  };

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];

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
})
