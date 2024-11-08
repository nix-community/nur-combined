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
  libiconv,
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
  version = "2.8-alt1";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = finalAttrs.version;
    hash = "sha256-bMF/20MXMnxTIROfHFLW3711GWqQTv72jbRpWtow4eA=";
    fetchSubmodules = true;
  };

  patches = [ ./0002-fix-build.patch ];

  postPatch =
    let
      srcFiles = [
        "docs/man/ms2render.htm"
        "docs/man/ms2view.htm"
        "docs/man/ms2view.txt"
        "docs/man/ms2vmap.htm"
        "docs/man/ms2vmapdb.htm"
        "modules/mapview/action_manager.cpp"
        "modules/mapview/mapview.cpp"
        "modules/vmap2/vmap2gobj.cpp"
        "modules/vmap2/vmap2types.cpp"
        "vmap_data/scripts/vmaps.sh"
        "vmap_data/scripts/vmaps_get_fig"
        "vmap_data/scripts/vmaps_in"
        "vmap_data/scripts/vmaps_mbtiles"
        "vmap_data/scripts/vmaps_out"
        "vmap_data/scripts/vmaps_preview"
        "vmap_data/scripts/vmaps_sqlitedb"
        "vmap_data/scripts/vmaps_wp_update"
      ];
    in
    ''
      ${lib.concatStringsSep "\n" (map (file: ''substituteInPlace ${file} --subst-var out'') srcFiles)}

      substituteInPlace modules/getopt/Makefile --replace-fail "SCRIPT_TESTS := getopt" ""
      substituteInPlace modules/opt/Makefile --replace-fail "SIMPLE_TESTS := opt" ""
      substituteInPlace modules/tmpdir/Makefile --replace-fail "SCRIPT_TESTS := tmpdir" ""
      substituteInPlace modules/get_deps --replace-fail "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
      patchShebangs .
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
  ] ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  env = {
    SKIP_IMG_DIFFS = 1;
    NIX_CFLAGS_COMPILE = "-std=c++17";
    NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-liconv";
  };

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
