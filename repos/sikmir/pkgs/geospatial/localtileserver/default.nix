{
  lib,
  python3Packages,
  fetchFromGitHub,
  large-image-source-gdal,
  server-thread,
}:

python3Packages.buildPythonApplication rec {
  pname = "localtileserver";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "localtileserver";
    rev = version;
    hash = "sha256-sSP9Cl+PJZZ8R8BcOko1yFDBpSLPKj6OpS0ZLLFP4GI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "large-image[gdal]" "large-image-source-gdal"
  '';

  propagatedBuildInputs = with python3Packages; [
    click
    flask
    flask-caching
    flask-cors
    flask-restx
    gdal
    large-image-source-gdal
    requests
    server-thread
    scooby
    setuptools
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_get_pine_gulch"
    "test_get_san_francisco"
    "test_get_oam2"
    "test_get_elevation_us"
    "test_folium_with_remote_client"
    "test_cog_validate"
    "test_tileclient_with_vsi"
    "test_home_page_with_file"
    "test_home_page"
    "test_cesium_split_view"
    "test_style_json"
    "test_multiple_tile_clients_one_server"
  ];

  meta = {
    description = "Local Tile Server for Geospatial Rasters";
    homepage = "https://localtileserver.banesullivan.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
}
