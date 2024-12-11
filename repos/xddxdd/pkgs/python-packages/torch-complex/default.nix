{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  torch,
  packaging,
}:
buildPythonPackage rec {
  inherit (sources.torch-complex) pname version src;

  propagatedBuildInputs = [
    torch
    packaging
  ];

  postPatch = ''
    substituteInPlace "setup.py" \
      --replace-fail "'pytest-runner'" ""
  '';

  pythonImportsCheck = [ "torch_complex" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Temporal python class for PyTorch-ComplexTensor";
    homepage = "https://pypi.org/project/torch-complex";
    license = with lib.licenses; [ asl20 ];
  };
}
