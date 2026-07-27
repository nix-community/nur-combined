{ nixpkgs, geopkgs, pythonVersion, postgresqlVersion }:

rec {

  # Place overrides under '>>> CUSTOMIZE HERE' line of desired package.

  # Run 'nix flake check --impure' to check your code.
  # Run 'nix run .#geonixcli -- shell' to enter customized shell environment.

  # Generic example

  # version = "XX.YY.ZZ";
  #
  # src = nixpkgs.fetchFromGitHub {
  #   owner = "<REPOSITORY-OWNER>";
  #   repo = "<REPOSITORY-NAME>";
  #   rev = "<GIT-REVISION>";
  #   hash = "<SHA256-HASH>";
  # };
  #
  # patches = [
  #   (nixpkgs.fetchpatch {
  #     name = "<PATCH-NAME>.patch";
  #     url = "https://github.com/<OWNER>/<REPO>/commit/<REVISION>.patch";
  #     hash = "<SHA256-HASH>";
  #   })
  #
  #   (nixpkgs.fetchpatch {
  #     name = "<PATCH-NAME>.patch";
  #     url = "https://github.com/<OWNER>/<REPO>/commit/<REVISION>.patch";
  #     hash = "<SHA256-HASH>";
  #   })
  # ];
  #
  # cmakeFlags = old.cmakeFlags ++ [
  #   "-D<FLAG_X>=ON"
  #   "-D<FLAG_Y>=OFF"
  # ];


  # Example of GDAL customization

  # version = "1000.0.0";
  #
  # patches = [
  #   (nixpkgs.fetchpatch {
  #     name = "test-patch.patch";
  #     url = "https://github.com/imincik/gdal/commit/6f91f4f91beea38cd8085866310589f4bb34caac.patch";
  #     hash = "sha256-NinvL2aMabkofX5D2RGR0cokj9rWGvcTjdC4v/Iehe8=";
  #   })
  # ];


  #####################################################################
  ### GDAL
  #####################################################################

  tiledb = geopkgs.tiledb;

  gdal = (geopkgs.gdal.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos libgeotiff libspatialite proj tiledb; useJava = false; };

  gdal-minimal = (geopkgs.gdal-minimal.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos libgeotiff libspatialite proj tiledb; useMinimalFeatures = true; };

  _gdal = gdal;

  #####################################################################
  ### GEOS
  #####################################################################

  geos = (geopkgs.geos.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { };

  #####################################################################
  ### LIBGEOTIFF
  #####################################################################

  libgeotiff = (geopkgs.libgeotiff.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit proj; };


  #####################################################################
  ### LIBRTTOPO
  #####################################################################

  librttopo = (geopkgs.librttopo.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos; };


  #####################################################################
  ### LIBSPATIALINDEX
  #####################################################################

  libspatialindex = (geopkgs.libspatialindex.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { };


  #####################################################################
  ### LIBSPATIALITE
  #####################################################################

  libspatialite = (geopkgs.libspatialite.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos librttopo proj; };


  #####################################################################
  ### PDAL
  #####################################################################

  pdal = (geopkgs.pdal.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit gdal libgeotiff tiledb; };


  #####################################################################
  ### PROJ
  #####################################################################

  proj = (geopkgs.proj.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { };


  python-packages = rec { ### PYTHON PACKAGES

  #####################################################################
  ### PYTHON3-FIONA
  #####################################################################

  fiona = (geopkgs."${pythonVersion}-fiona".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit gdal; };

  #####################################################################
  ### PYTHON3-GDAL
  #####################################################################

  gdal = nixpkgs.${pythonVersion}.pkgs.toPythonModule (_gdal);   # nothing to override here

  #####################################################################
  ### PYTHON3-GEOPANDAS
  #####################################################################

  geopandas = (geopkgs."${pythonVersion}-geopandas".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit pyogrio pyproj shapely; };

  #####################################################################
  ### PYTHON3-OWSLIB
  #####################################################################

  owslib = (geopkgs."${pythonVersion}-owslib".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit pyproj; };

  #####################################################################
  ### PYTHON3-PSYCOPG
  #####################################################################

  psycopg = (geopkgs."${pythonVersion}-psycopg".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit shapely; };

  #####################################################################
  ### PYTHON3-PYOGRIO
  #####################################################################

  pyogrio = (geopkgs."${pythonVersion}-pyogrio".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit gdal; };

  #####################################################################
  ### PYTHON3-PYPROJ
  #####################################################################

  pyproj = (geopkgs."${pythonVersion}-pyproj".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit proj shapely; };

  #####################################################################
  ### PYTHON3-PYQT5
  #####################################################################

  pyqt5 = geopkgs."${pythonVersion}-pyqt5";  # nothing to override here

  #####################################################################
  ### PYTHON3-PYSTAC
  #####################################################################

  pystac = (geopkgs."${pythonVersion}-pystac".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { };

  #####################################################################
  ### PYTHON3-RASTERIO
  #####################################################################

  rasterio = (geopkgs."${pythonVersion}-rasterio".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit gdal shapely; };

  #####################################################################
  ### PYTHON3-SHAPELY
  #####################################################################

  shapely = (geopkgs."${pythonVersion}-shapely".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos; };

  }; ### PYTHON PACKAGES


  postgresql-packages = rec { ### POSTGRESQL PACKAGES

  #####################################################################
  ### POSTGIS
  #####################################################################

  postgis = (geopkgs."${postgresqlVersion}-postgis".overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit geos proj; gdalMinimal = gdal-minimal; };

  }; ### POSTGRESQL PACKAGES


  #####################################################################
  ### GRASS
  #####################################################################

  grass = (geopkgs.grass.overrideAttrs (old: {

    # >>> CUSTOMIZE HERE

  })).override { inherit gdal geos pdal proj; };


  #####################################################################
  ### QGIS
  #####################################################################

  # QGIS
  qgis-python =
    let
      packageOverrides = final: prev: {
        pyqt5 = python-packages.pyqt5;
        owslib = python-packages.owslib;
        gdal = python-packages.gdal;
      };
    in
    nixpkgs.${pythonVersion}.override { inherit packageOverrides; self = qgis-python; };

  qgis-unwrapped = (geopkgs.qgis-unwrapped.overrideAttrs (old: {

      # >>> CUSTOMIZE HERE

    })).override {
        inherit geos gdal libspatialindex libspatialite pdal proj;
        python3 = qgis-python;
    };

  qgis = geopkgs.qgis.override { qgis-unwrapped = qgis-unwrapped; };

  # QGIS-LTR
  qgis-ltr-unwrapped = (geopkgs.qgis-ltr-unwrapped.overrideAttrs (old: {

      # >>> CUSTOMIZE HERE

    })).override {
        inherit geos gdal libspatialindex libspatialite pdal proj;
        python3 = qgis-python;
    };

  qgis-ltr = geopkgs.qgis-ltr.override { qgis-ltr-unwrapped = qgis-ltr-unwrapped; };

}
