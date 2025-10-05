{
  lib,
  fetchFromGitHub,
  python3Packages,
  pymbtiles,
}:

python3Packages.buildPythonApplication rec {
  pname = "tpkutils";
  version = "0.8.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "consbio";
    repo = "tpkutils";
    tag = version;
    hash = "sha256-iKM+tEEOtSkwDdkBN+n35q3D2IBi7a/bnY/fSlGDowU=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    mercantile
    pymbtiles
    six
    setuptools # pkg_resources
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "ArcGIS Tile Package Utilities";
    homepage = "https://github.com/consbio/tpkutils";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tpk";
  };
}
