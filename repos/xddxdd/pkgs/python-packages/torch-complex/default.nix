{
  fetchurl,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  torch,
  numpy,
  packaging,
}:
buildPythonPackage (finalAttrs: {
  pname = "torch-complex";
  version = "0.4.4";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/t/torch_complex/torch_complex-${finalAttrs.version}.tar.gz";
    hash = "sha256-QVP9aySgutaJ5vGTv70A84KDsYkNgIvvaE3cbR9j/T8=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    torch
    numpy
    packaging
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail "'pytest-runner'" ""
  '';

  pythonImportsCheck = [ "torch_complex" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Temporal python class for PyTorch-ComplexTensor";
    homepage = "https://pypi.org/project/torch-complex";
    license = with lib.licenses; [ asl20 ];
  };
})
