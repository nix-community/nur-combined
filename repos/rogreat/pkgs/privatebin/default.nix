{
  base58,
  buildPythonPackage,
  coverage,
  cryptography,
  fetchFromGitHub,
  hatchling,
  httpx,
  lib,
  msgspec,
  pytest-httpx,
  pytest-socket,
  pytestCheckHook,
  tomli,
}:

buildPythonPackage (finalAttrs: {
  pname = "privatebin";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Ravencentric";
    repo = "privatebin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jydJJdC7N4fyawTeEUJJgPNbfSJfRU1xYjCRffx842k=";
  };

  build-system = [ hatchling ];

  dependencies = [
    base58
    cryptography
    httpx
    msgspec
  ];

  nativeCheckInputs = [
    coverage
    pytest-httpx
    pytest-socket
    pytestCheckHook
    tomli
  ];

  meta = {
    description = "Python library for interacting with PrivateBin's v2 API";
    homepage = "https://github.com/Ravencentric/privatebin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
