{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.comp128) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  pythonImportsCheck = [ "comp128" ];

  meta = {
    changelog = "https://github.com/Takuto88/comp128-python/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of the Comp128 v1-3 GSM authentication algorithms";
    homepage = "https://github.com/Takuto88/comp128-python";
    license = with lib.licenses; [ gpl2Only ];
  };
}
