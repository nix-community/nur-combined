{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "geoutils";
  version = "0.1.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "GlacioHack";
    repo = "geoutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EfDqr0nKRCoypi7cX3B1Smiw4IaWqQf0v/CpTAFQpzw=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    affine
    dask
    geopandas
    matplotlib
    numpy
    pandas
    pyproj
    rasterio
    rioxarray
    scipy
    shapely
    tqdm
    xarray
  ];

  doCheck = false; # requires network access

  meta = {
    description = "Analysis of georeferenced rasters, vectors and point clouds";
    homepage = "https://github.com/GlacioHack/geoutils";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.isDarwin; # postgresql-test-hook
  };
})
