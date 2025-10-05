{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "supermercado";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "supermercado";
    rev = "44841a07adff32665fae736f9ba7df8c7b24ac44";
    hash = "sha256-k2S1aOHQEJq//4mdWZ5GhJQJjKqJuDbBztoHi373s6w=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click-plugins
    rasterio
    mercantile
    numpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Supercharger for mercantile";
    homepage = "https://github.com/mapbox/supermercado";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
