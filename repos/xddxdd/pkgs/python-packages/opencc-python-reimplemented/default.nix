{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.opencc-python-reimplemented) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  pythonImportsCheck = [ "opencc" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenCC made with Python";
    homepage = "https://github.com/yichen0831/opencc-python";
    license = with lib.licenses; [ asl20 ];
  };
}
