{ python3Packages
, fetchFromGitHub
, datasette-leaflet
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pname = "datasette-cluster-map";
  version = "0.17.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "datasette-cluster-map";
    rev = version;
    hash = "sha256-KSmL4xHkeXh8gVEUkvZBjYMlttPJHVr0AkbnRJ/NLFc=";
  };

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

  pythonImportsCheck = [ "datasette_cluster_map" ];

  meta = {
    description = "Datasette plugin that shows a map for any data with latitude/longitude columns";
    homepage = "https://github.com/simonw/datasette-cluster-map";
    license = lib.licenses.asl20;
  };
}
