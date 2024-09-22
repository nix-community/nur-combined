{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "prettymapp";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "chrieke";
    repo = "prettymapp";
    rev = version;
    hash = "sha256-6UO2+pvtm3t6LjC2v91NJVLVo74Bdx1xzpHqvL15UCg=";
  };

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
  };
}
