{
  base58,
  buildPythonPackage,
  cryptography,
  fetchFromGitHub,
  hatchling,
  httpx,
  lib,
  msgspec,
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

  doCheck = false;

  pythonImportsCheck = [ "privatebin" ];

  meta = {
    description = "Python library for interacting with PrivateBin's v2 API";
    homepage = "https://github.com/Ravencentric/privatebin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
