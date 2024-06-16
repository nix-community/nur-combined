{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "geoarrow-c";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-c";
    rev = "v${version}";
    hash = "sha256-uEB+D3HhrjnCgExhguZkmvYzULWo5gAWxXeIGQOssqo=";
  };

  sourceRoot = "${src.name}/python/geoarrow-c";

  build-system = with python3Packages; [ setuptools-scm ];

  nativeBuildInputs = with python3Packages; [ cython ];

  meta = {
    description = "Experimental C and C++ implementation of the GeoArrow specification";
    homepage = "http://geoarrow.org/geoarrow-c/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
