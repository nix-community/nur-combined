{
  lib,
  python3Packages,
  fetchFromGitHub,
  pycouchdb,
}:

python3Packages.buildPythonPackage rec {
  pname = "hardpy";
  version = "0.4.0";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "everypinio";
    repo = "hardpy";
    rev = version;
    hash = "sha256-CVn5Edon1auXNFFNRGnt2i1j9TJo+uX194a22tIQpVE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.21.1" "hatchling"
  '';

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    pycouchdb
    glom
    pydantic
    natsort
    fastapi
    uvicorn
    pytest
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "HardPy library for device testing";
    homepage = "https://everypinio.github.io/hardpy/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
