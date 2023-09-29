{ buildPythonPackage
, fetchPypi
, datasette-leaflet
, lib
}:

buildPythonPackage rec {
  pname = "datasette-cluster-map";
  version = "0.17.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "863854f7ee3d037b172a696b5a0861648394502514087745e2224da5a0135622";
  };
  propagatedBuildInputs = [
    datasette-leaflet
  ];
  doCheck = false;
  pythonImportsCheck = [ "datasette_cluster_map" ];
  meta = {
    description = "Datasette plugin that shows a map for any data with latitude/longitude columns";
    homepage = "https://github.com/simonw/datasette-cluster-map";
    license = lib.licenses.asl20;
  };
}
