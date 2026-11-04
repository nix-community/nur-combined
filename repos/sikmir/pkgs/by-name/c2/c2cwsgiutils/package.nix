{
  lib,
  fetchFromGitHub,
  python3Packages,
  cee-syslog-handler,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "c2cwsgiutils";
  version = "6.1.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "c2cwsgiutils";
    tag = finalAttrs.version;
    hash = "sha256-ZhPqeymCM/t91Ao5+9NPM1y4DikDX2d/SiGfavXPAZk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"' \
      --replace-fail "poetry-dynamic-versioning[plugin]" "poetry-dynamic-versioning" \
      --replace-fail "\"poetry-plugin-tweak-dependencies-version\"," "" \
      --replace-fail "\"poetry-plugin-drop-python-upper-constraint\"," ""
  '';

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    boltons
    cee-syslog-handler
    lxml
    netifaces
    pillow
    psycopg2
    pyramid
    pyyaml
    requests
    ujson
    urllib3
    waitress
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
