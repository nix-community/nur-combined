{ lib, python3Packages, large-image, gdal }:

{
  source-gdal = python3Packages.buildPythonPackage rec {
    pname = "large-image-source-gdal";
    inherit (large-image) version src nativeBuildInputs meta;
    sourceRoot = "${src.name}/sources/gdal";

    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    propagatedBuildInputs = with python3Packages; [ gdal pyproj large-image ];

    doCheck = false;
  };
}
