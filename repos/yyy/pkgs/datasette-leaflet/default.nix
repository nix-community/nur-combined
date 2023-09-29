{ buildPythonPackage
, fetchPypi
, datasette
}:

buildPythonPackage rec {
  pname = "datasette-leaflet";
  version = "0.2.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "8fd4e634304be392ae6f7de770d4f22b95a37caecd676a35faeb6200da9423bc";
  };
  propagatedBuildInputs = [ datasette ];
  doCheck = false;
  pythonImportsCheck = [ "datasette_leaflet" ];
  meta = {
    description = "Datasette plugin adding the Leaflet JavaScript library";
    homepage = "https://github.com/simonw/datasette-leaflet";
  };
}
