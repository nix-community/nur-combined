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
}:
buildPythonPackage (finalAttrs: {
  pname = "cache-dit";
  version = "1.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vipshop";
    repo = "cache-dit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zOgB1mAgW7MKFjElIbHFDQBwQET6erAK1MBcyMHpXkg=";
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

  meta = {
    description = "Cache-DiT: Accelerating Diffusion Transformers with Dynamic Feature Caching";
    homepage = "https://github.com/vipshop/cache-dit";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    broken = lib.strings.versionAtLeast python.version "3.15"; # Broken on 3.15
  };
})
