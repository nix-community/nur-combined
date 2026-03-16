{ python3Packages
, generated
, datasette-leaflet
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    # datasette
    datasette-leaflet
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    httpx
    sqlite-utils
  ];

  pytestCheckPhase = ":"; # ModuleNotFoundError: No module named 'datasette_test'

  pythonImportsCheck = [ "datasette_cluster_map" ];

  meta = {
    description = "Datasette plugin that shows a map for any data with latitude/longitude columns";
    homepage = "https://github.com/simonw/datasette-cluster-map";
    license = lib.licenses.asl20;
  };
}
