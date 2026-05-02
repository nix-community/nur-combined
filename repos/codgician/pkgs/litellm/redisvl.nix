# Pure-Python redisvl - tracked at upstream's latest, kept fresh with
# nix-update-script. LiteLLM still pins `redisvl==0.4.1`, but only imports
# `SemanticCache` and `CustomTextVectorizer`, both of which remain
# available (via a backward-compatibility shim) in newer redisvl releases.
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  hatchling,
  numpy,
  pyyaml,
  redis,
  pydantic,
  tenacity,
  ml-dtypes,
  python-ulid,
  jsonpath-ng,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "redisvl";
  version = "0.18.1";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "redis";
    repo = "redis-vl-python";
    tag = "v${version}";
    hash = "sha256-2yByWnnHYUBsjUCqyEv70+S0GCFEb7y2BGw4kHbaC+0=";
  };

  build-system = [ hatchling ];

  pythonRelaxDeps = [
    "ml-dtypes"
    "redis"
  ];

  dependencies = [
    numpy
    pyyaml
    redis
    pydantic
    tenacity
    ml-dtypes
    python-ulid
    jsonpath-ng
  ];

  pythonImportsCheck = [ "redisvl" ];

  # Tests need a live Redis with vector search module.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python client library and CLI for using Redis as a vector database";
    homepage = "https://github.com/redis/redis-vl-python";
    changelog = "https://github.com/redis/redis-vl-python/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
