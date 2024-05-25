{
  lib,
  stdenv,
  fetchFromGitHub,
  substituteAll,
  copyDesktopItems,
  desktopToDarwinBundle,
  makeDesktopItem,
  db,
  fig2dev,
  giflib,
  gsettings-desktop-schemas,
  gtkmm3,
  imagemagick,
  jansson,
  curl,
  libjpeg,
  libpng,
  librsvg,
  libtiff,
  libxml2,
  libzip,
  perlPackages,
  pkg-config,
  proj,
  shapelib,
  unzip,
  wrapGAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mapsoft2";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = "${finalAttrs.version}-alt1";
    hash = "sha256-XT3oDPu+GE3WfzlDk7jELhGmPknL0m+cgTxH4opGjFs=";
    fetchSubmodules = true;
  };

  patches = [ ./0002-fix-build.patch ];

  postPatch = ''
    substituteInPlace modules/getopt/Makefile \
      --replace-fail "SCRIPT_TESTS := getopt" ""
    substituteInPlace modules/opt/Makefile \
      --replace-fail "SIMPLE_TESTS := opt" ""
    substituteInPlace modules/tmpdir/Makefile \
      --replace-fail "SCRIPT_TESTS := tmpdir" ""
    substituteInPlace modules/get_deps \
      --replace-fail "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    substituteInPlace modules/mapview/mapview.cpp \
      --replace-fail "/usr/share" "$out/share"
    patchShebangs .

    substituteInPlace vmap_data/scripts/vmaps_preview --replace-fail "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_out --replace-fail "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_get_fig --replace-fail "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_in --replace-fail "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps.sh --replace-fail "/usr" "$out"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ms2view";
      exec = "ms2view";
      comment = "Viewer for geodata and raster maps";
      desktopName = "ms2view";
      genericName = "Mapsoft2 viewer";
      categories = [
        "Geography"
        "Geoscience"
        "Science"
      ];
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    fig2dev
    imagemagick
    perlPackages.perl
    pkg-config
    unzip
    wrapGAppsHook
  ] ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [
    db
    giflib
    gsettings-desktop-schemas
    gtkmm3
    jansson
    curl
    libjpeg
    libpng
    librsvg
    libtiff
    libxml2
    libzip
    proj
    shapelib
  ];

  SKIP_IMG_DIFFS = 1;

  makeFlags = [ "prefix=$(out)" ];

  dontWrapGApps = true;

  postFixup = ''
    for f in $out/bin/ms2*; do
      wrapGApp $f
    done
  '';

  meta = {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
  };
})
