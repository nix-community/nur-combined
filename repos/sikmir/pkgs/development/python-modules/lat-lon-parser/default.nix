{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "lat-lon-parser";
  version = "1.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "NOAA-ORR-ERD";
    repo = "lat_lon_parser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JO3s7C0aY2vX8QZI1UOzLaQI+VSdhUxiHHjqBxm1QW4=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Simple parser for latitude-longitude strings";
    homepage = "https://github.com/NOAA-ORR-ERD/lat_lon_parser";
    license = lib.licenses.cc0;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
