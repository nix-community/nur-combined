{
  sources,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  inherit (sources.xue) pname version src;

  propagatedBuildInputs = [
    python3Packages.httpx
  ];

  pythonImportsCheck = [ "xue" ];

  meta = {
    description = "Minimalist web front-end framework composed of HTMX and Python";
    homepage = "https://pypi.org/project/xue/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
}
