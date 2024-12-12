{
  lib,
  fetchFromGitHub,
  python3Packages,
  geoarrow-c,
}:

python3Packages.buildPythonPackage rec {
  pname = "geoarrow-pyarrow";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-python";
    tag = "v${version}";
    hash = "sha256-Ni+GKTRhRDRHip1us3OZPuUhHQCNU7Nap865T/+CU8Y=";
  };

  sourceRoot = "${src.name}/geoarrow-pyarrow";

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    geoarrow-c
    pyarrow
    pyarrow-hotfix
  ];

  meta = {
    description = "Python implementation of the GeoArrow specification";
    homepage = "https://github.com/geoarrow/geoarrow-python";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
