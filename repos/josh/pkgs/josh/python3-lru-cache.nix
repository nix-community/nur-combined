{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "lru-cache";
  version = "1.0.2";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "lru-cache-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p+pQdBBRxWwyymvWUtvcs3dVAuyE+nAzZj1jAi8tKFk=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  pythonImportsCheck = [ "lru_cache" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    homepage = "https://github.com/josh/lru-cache-python";
    description = "Persisted LRU cache Python module";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
