{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  cogdumper,
}:

python3Packages.buildPythonPackage rec {
  pname = "rio-cogeo";
  version = "5.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    rev = version;
    hash = "sha256-4zye0JksG9YCc+eyWbYFEW0k8eqqiSlY1uv0M+8qZwA=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    cogdumper
  ];

  meta = with lib; {
    description = "Cloud Optimized GeoTIFF creation and validation plugin for rasterio";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
