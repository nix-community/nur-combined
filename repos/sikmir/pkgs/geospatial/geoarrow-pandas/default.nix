{
  lib,
  fetchFromGitHub,
  python3Packages,
  geoarrow-pyarrow,
}:

python3Packages.buildPythonPackage rec {
  pname = "geoarrow-pandas";
  inherit (geoarrow-pyarrow) version src;
  pyproject = true;

  sourceRoot = "${src.name}/geoarrow-pandas";

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    geoarrow-pyarrow
    pandas
    pyarrow
  ];

  meta = {
    description = "Python implementation of the GeoArrow specification";
    homepage = "https://github.com/geoarrow/geoarrow-python";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
