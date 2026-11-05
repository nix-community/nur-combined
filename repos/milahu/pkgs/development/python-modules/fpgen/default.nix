# FIXME fpgen should use a model from the Nix store
# Fetching model files from GitHub...
# OSError: [Errno 30] Read-only file system: '/nix/store/xzpr45p0hsjsgaamwz4xh1xxvw7yaiih-python3-3.14.7-env/lib/python3.14/site-packages/fpgen/data'

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  click,
  httpx,
  indexed-zstd,
  numpy,
  orjson,
  zstandard,
  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "fpgen";
  # https://pypi.org/project/fpgen/#history
  version = "1.3.0"; # 2025-03-22
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "scrapfly";
    repo = "fingerprint-generator";
    # tag = "model-4/2025";
    tag = "model-2/2026";
    hash = "sha256-y+Yh+BXbzZI51aEe3+92uYzfGRJzD/rPU5XJusoUDfY=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    click
    httpx
    indexed-zstd
    numpy
    orjson
    zstandard
  ];

  # import fails: "Fetching model files from GitHub..."
  # pythonImportsCheck = [ "fpgen" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Browser fingerprint data generator";
    homepage = "https://github.com/scrapfly/fingerprint-generator";
    # changelog = "https://github.com/scrapfly/fingerprint-generator/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
