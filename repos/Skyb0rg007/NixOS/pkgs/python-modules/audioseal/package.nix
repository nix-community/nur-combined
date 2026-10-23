{
  lib,
  fetchPypi,
  buildPythonPackage,
  flit-core,
  einops,
  numpy,
  omegaconf,
  torch,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "audioseal";
  version = "0.2.0";
  __structuredAttrs = true;
  pyproject = true;

  # Upstream does not tag releases on GitHub.
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-VpoW64mHSOp/P11IXglOId3OvWgxSthzBRp56eW3CK4=";
  };

  # Only flit_core is used; the other pins are leftovers.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["flit_core >=3.2,<4", "packaging~=23.1", "setuptools~=67.8", "wheel~=0.40"]' \
        'requires = ["flit_core >=3.2,<4"]'
  '';

  build-system = [ flit-core ];

  dependencies = [
    einops
    numpy
    omegaconf
    torch
  ];

  pythonImportsCheck = [ "audioseal" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Localized watermarking for AI-generated speech";
    homepage = "https://github.com/facebookresearch/audioseal";
    changelog = "https://github.com/facebookresearch/audioseal/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
