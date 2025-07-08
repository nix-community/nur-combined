{
  sources,
  lib,
  buildPythonPackage,
  setuptools,
  # Dependencies
  httpx,
}:

buildPythonPackage {
  inherit (sources.xue) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  propagatedBuildInputs = [ httpx ];

  pythonImportsCheck = [ "xue" ];

  meta = {
    description = "Minimalist web front-end framework composed of HTMX and Python";
    homepage = "https://pypi.org/project/xue/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
}
