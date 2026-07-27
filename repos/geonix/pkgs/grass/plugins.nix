{ lib
, stdenv
, fetchFromGitHub

, name
, plugin

, boost
, cgal
, fftw
, gmp
, grass
, libtiff
, mpfr
, pkg-config
, postgresql
, python3

, geopkgs-python3
}:

let
  srcRevision = import ./plugins-rev.nix;
in
stdenv.mkDerivation {
  pname = "grass-plugin-${name}";
  version = "git-${srcRevision.rev}";
 
  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "grass-addons";
    rev = srcRevision.rev;
    hash = srcRevision.hash;
  };

  postPatch = ''
    # make scripts executable, otherwise they are not processed by patchShebangs
    plugin_src=$(find . -type d -name '${plugin.name}')
    find $plugin_src -type f -name "*.sh" -exec chmod 744 {} \;
    find $plugin_src -type f -name "*.py" -exec chmod 744 {} \;

    patchShebangs $plugin_src

    # remove pyc files
    find . -name '*.pyc' -type f -delete
  '';

  nativeBuildInputs = with python3.pkgs; [
    pkg-config

    grass
    postgresql  # for libpq-fe.h
    python3

    # python
    matplotlib
    numpy
    six
  ] ++ (with geopkgs-python3; [
    gdal
  ]);

  # extra plugin dependencies (both Python and non-python)
  propagatedBuildInputs = with python3.pkgs; [ ]
    # python
    ++ lib.optionals (name == "m-cdo-download") [ requests ]
    ++ lib.optionals (name == "m-tnm-download") [ requests ]
    ++ lib.optionals (name == "r-edm-eval") [ pandas ]
    ++ lib.optionals (name == "i-eodag") [ pytz ]
    ++ lib.optionals (name == "wx-metadata") [ wxpython ]
    ++ lib.optionals (name == "r-in-vect") [ (geopkgs-python3.gdal) ]
    ++ lib.optionals (name == "i-landsat") [ pyyaml]
    # ++ lib.optionals (name == "i-sentinel") [ pystac ]

    # non python
    ++ lib.optionals (name == "r-out-tiff") [ libtiff ]
    ++ lib.optionals (name == "v-delaunay3d") [ boost cgal gmp mpfr ]
    ++ lib.optionals (name == "i-points-auto") [ fftw ]
  ;

  # see: https://github.com/OSGeo/grass/blob/75375c90ab6057ac9aa2dc1642a62ccc54da7624/scripts/g.extension/g.extension.py#L2046
  buildPhase = let
    gmajor = lib.versions.major grass.version;
    gminor = lib.versions.minor grass.version;

    in ''
    builddir=$(pwd)/build

    cp -a ${grass}/grass${gmajor}${gminor} grasscopy
    find grasscopy -type f -exec chmod 666 {} \;
    find grasscopy -type d -exec chmod 777 {} \;

    GISRC=$(pwd)/grasscopy/demolocation/.grassrc${gmajor}${gminor}
    sed -i "s|GISDBASE:.*|GISDBASE: $(pwd)/grasscopy|" $GISRC

    pushd $(find . -type d -name '${plugin.name}')

    make \
      MODULE_TOPDIR=${grass} \
      BIN=$builddir/bin \
      HTMLDIR=$builddir/docs/html \
      RESTDIR=$builddir/docs/rest \
      MANBASEDIR=$builddir/docs/man \
      SCRIPTDIR=$builddir/scripts \
      STRINGDIR=$(pwd) \
      ETC=$builddir/etc \
      RUN_GISRC=$GISRC

    popd
  '';

  # see: https://github.com/OSGeo/grass/blob/75375c90ab6057ac9aa2dc1642a62ccc54da7624/scripts/g.extension/g.extension.py#L2060
  installPhase = ''
    cp -a $(pwd)/build $out
  '';

  meta = with lib; {
    description = "GRASS plugin: " + plugin.description;
    homepage = "https://github.com/OSGeo/grass-addons";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; teams.geospatial.members;
    platforms = platforms.all;
  };
}
