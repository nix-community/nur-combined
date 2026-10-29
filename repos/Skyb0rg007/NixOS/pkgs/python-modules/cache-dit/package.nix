{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  packaging,
  pyyaml,
  torch,
  diffusers,
  transformers,
  python,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "cache-dit";
  version = "1.5.3";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vipshop";
    repo = "cache-dit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A6VWLtY05yKWUsGYSO4iAeviBYyEhfM85EeBr7eUI6s=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    diffusers
    packaging
    pyyaml
    torch
    transformers
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v([0-9.]+)$" ];
  };

  meta = {
    description = "Cache-DiT: Accelerating Diffusion Transformers with Dynamic Feature Caching";
    homepage = "https://github.com/vipshop/cache-dit";
    changelog = "https://github.com/vipshop/cache-dit/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    broken = lib.strings.versionAtLeast python.version "3.15"; # Broken on 3.15
  };
})
