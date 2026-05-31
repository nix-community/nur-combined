{
  lib,
  python3Packages,
  fetchFromGitHub,
  rio-cogeo,
  server-thread,
  jupyter-loopback,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "localtileserver";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "localtileserver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m4zNJ/N7oESXQsJDFu0wNp0xw4y3ror9p+ynvs2xnMA=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    click
    flask
    flask-caching
    flask-cors
    flask-restx
    jupyter-loopback
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
  };
})
