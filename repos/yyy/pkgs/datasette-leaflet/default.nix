{ python3Packages
, fetchFromGitHub
}:

with python3Packages;
buildPythonPackage rec {
  pname = "datasette-leaflet";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "datasette-leaflet";
    rev = version;
    hash = "sha256-wkVzF96fdsjxbuitITgI9XOdfhE0W1aNCjP/I03tu8c=";
  };

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
