{
  sources,
  lib,
  buildPythonPackage,
  # Dependencies
  httpx,
}:

buildPythonPackage {
  inherit (sources.xue) pname version src;

  propagatedBuildInputs = [ httpx ];

  pythonImportsCheck = [ "xue" ];

  meta = {
    description = "Minimalist web front-end framework composed of HTMX and Python";
    homepage = "https://pypi.org/project/xue/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
}
