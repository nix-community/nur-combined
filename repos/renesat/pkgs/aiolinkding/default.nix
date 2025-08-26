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
  version = "2025.02.0";
  format = "pyproject";

  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aiolinkding";
    tag = version;
    hash = "sha256-6ITeZJf5PlaF41ZrdHHFxhFFLCncbdRL6EfjiZuc3H4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry-core==2.0.1" "poetry-core>=2.0.1"
  '';

  build-system = [poetry-core setuptools];

  pythonRelaxDeps = [
    "frozenlist"
    "packaging"
  ];

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
