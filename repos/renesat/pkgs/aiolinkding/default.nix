{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  setuptools,
  aiohttp,
  certifi,
  frozenlist,
  packaging,
  python,
  yarl,
  pytestCheckHook,
  aresponses,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "aiolinkding";
  version = "2023.12.0";
  format = "pyproject";

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aiolinkding";
    rev = version;
    hash = "sha256-1or6sh8mKIBxnRCuxfnslmKyQPCzqURqPgg9NFi1tRI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry>=0.12" "poetry-core>=0.12" \
      --replace-fail "packaging = \"^23.0\"" "packaging = \"^24.0\""
  '';

  build-system = [poetry-core setuptools];

  dependencies = [
    aiohttp
    certifi
    frozenlist
    packaging
    python
    yarl
  ];

  nativeCheckInputs = [
    pytestCheckHook
    aresponses
  ];

  pytestFlagsArray = [
    "tests/"
  ];

  pythonImportsCheck = [
    "aiolinkding"
  ];

  meta = with lib; {
    description = "A Python3, async interface to the linkding REST API";
    homepage = "https://github.com/bachya/aiolinkding";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
  };
}
