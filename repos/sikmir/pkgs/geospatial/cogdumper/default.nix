{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "cogdumper";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "COGDumper";
    rev = "89a5f05fc0ed88c36f44e42dfe8d48e4c4ff389b";
    hash = "sha256-gLBBGP2AMKP8biSbMtrxGs7vLDXbP+Y6Ct82FiNdNjs=";
  };

  nativeBuildInputs = with python3Packages; [ ];

  propagatedBuildInputs = with python3Packages; [ ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Dumps tiles out of a cloud optimized geotiff";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
