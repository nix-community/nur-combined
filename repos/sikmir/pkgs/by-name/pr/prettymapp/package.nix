{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "prettymapp";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrieke";
    repo = "prettymapp";
    tag = version;
    hash = "sha256-kjfxHjKLISGXNovX4CPW0cbQizGw1LebXh8yDTAkeYk=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ osmnx ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    mock
  ];

  disabledTests = [
    "test_get_aoi_from_user_input_address"
    "test_get_aoi_from_user_input_rectangle"
    "test_get_aoi_from_user_input_coordinates"
    "test_get_osm_geometries_from_xml"
  ];

  meta = {
    description = "Create beautiful maps from OpenStreetMap data in a webapp";
    homepage = "https://github.com/chrieke/prettymapp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # osmnx
  };
}
