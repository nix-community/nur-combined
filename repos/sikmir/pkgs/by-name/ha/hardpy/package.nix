{
  lib,
  python3Packages,
  fetchFromGitHub,
  pycouchdb,
  requests-oauth2client,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "hardpy";
  version = "0.22.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "everypinio";
    repo = "hardpy";
    tag = finalAttrs.version;
    hash = "sha256-LxM5Q3XZnL3iJT2c7nSo44PWm98hP+pI2B1SuQfTGZY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.27.0" "hatchling"
  '';

  build-system = with python3Packages; [ hatchling ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    fastapi
    glom
    jinja2
    keyring
    natsort
    oauthlib
    py-machineid
    pycouchdb
    pydantic
    pytest
    qrcode
    requests
    requests-oauth2client
    requests-oauthlib
    tomli
    tomli-w
    typer
    tzlocal
    uuid6
    uvicorn
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "HardPy library for device testing";
    homepage = "https://everypinio.github.io/hardpy/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
