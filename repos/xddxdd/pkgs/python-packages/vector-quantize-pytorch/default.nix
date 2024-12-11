{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  einops,
  einx,
  hatchling,
  torch,
}:
buildPythonPackage rec {
  inherit (sources.vector-quantize-pytorch) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    einops
    einx
    hatchling
    torch
  ];

  pythonImportsCheck = [ "vector_quantize_pytorch" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Vector (and Scalar) Quantization, in Pytorch";
    homepage = "https://github.com/lucidrains/vector-quantize-pytorch";
    license = with lib.licenses; [ mit ];
  };
}
