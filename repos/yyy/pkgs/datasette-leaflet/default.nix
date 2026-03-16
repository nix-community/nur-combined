{ python3Packages
, generated
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [ setuptools ];

  propagatedBuildInputs = [ datasette ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  pythonImportsCheck = [ "datasette_leaflet" ];

  meta = {
    description = "Datasette plugin adding the Leaflet JavaScript library";
    homepage = "https://github.com/simonw/datasette-leaflet";
  };
}
