{
  lib,
  python3Packages,
  fetchFromGitHub,
  rio-cogeo,
  server-thread,
}:

python3Packages.buildPythonApplication rec {
  pname = "localtileserver";
  version = "0.10.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "localtileserver";
    tag = "v${version}";
    hash = "sha256-09POlT+3gWGoP/tKRur9OaFsfQvC4OwSHE+ssqSQi1Q=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    flask
    flask-caching
    flask-cors
    flask-restx
    rio-tiler
    rio-cogeo
    requests
    server-thread
    setuptools
    scooby
    werkzeug
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    matplotlib
  ];

  disabledTests = [
    "test_create_tile_client"
    "test_is_valid_palette_name"
    "test_home_page_with_file"
    "test_home_page"
    "test_cesium_split_view"
    "test_style"
    "test_cog_validate_endpoint"
    "test_get_pine_gulch"
    "test_get_oam2"
    "test_cog_validate"
    "test_tileclient_with_vsi"
  ];

  meta = {
    description = "Local Tile Server for Geospatial Rasters";
    homepage = "https://localtileserver.banesullivan.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    inherit (python3Packages.rio-tiler.meta) broken;
  };
}
