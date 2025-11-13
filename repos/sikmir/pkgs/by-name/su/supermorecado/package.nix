{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "supermorecado";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "supermorecado";
    tag = version;
    hash = "sha256-CuuJ4B/f7JoGQuTo5LS3WqMD860tucZ6z/97atw94k0=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    morecantile
    rasterio
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_burn_tile_center_point_roundtrip"
    "test_burn_tile_center_lines_roundtrip"
    "test_burn_cli_tile_shape"
  ];

  meta = {
    description = "Extend the functionality of morecantile with additional commands";
    homepage = "https://github.com/developmentseed/supermorecado";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
