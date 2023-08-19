{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, substituteAll
, copyDesktopItems
, desktopToDarwinBundle
, makeDesktopItem
, db
, fig2dev
, giflib
, gsettings-desktop-schemas
, gtkmm3
, imagemagick
, jansson
, curl
, libjpeg
, libpng
, librsvg
, libtiff
, libxml2
, libzip
, perlPackages
, pkg-config
, proj
, shapelib
, unzip
, wrapGAppsHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mapsoft2";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = "${finalAttrs.version}-alt1";
    hash = "sha256-++v9rlBmH/65XwI7uz6Vdk8NAPOq5jwwqiKpzxD76A8=";
    fetchSubmodules = true;
  };

  patches = [
    (substituteAll {
      src = ./0002-fix-build.patch;
      db = db.dev;
      inherit giflib;
    })
    # conv_geo: update test for libproj-9.2.0
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/9300f93e171769bbf8710d9dfa5f2724b7b6142d.patch";
      hash = "sha256-2rzjCwJ+BKJB7YFfZFprPjLn/MZO7sSoHcDKNTjhbT8=";
    })
    # filename: fix for macOS build
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/0cda5141d29dd1a8f0e0a1f38211faac2fc7b297.patch";
      hash = "sha256-ESnPAWKv4qtWHuqRt4XABret85BUMuAkcahEQPdkGfI=";
    })
    # tmpdir: include unistd.h for macOS build
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/7805967a44498c430daa577615878218d14ae4a7.patch";
      hash = "sha256-P8JRMhRkaRZZHxojhpfJTJ6vCC6TfXnOdB2KHzZy3eE=";
    })
    # geom: attempt to fix MacOS build
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/256e16816e13e0f88a7442ef4e4e9a5533d5481b.patch";
      hash = "sha256-gJrv3aTNe/lwuZ4mzcdEJzGWPFKEYPqIqKNKEKddNJ4=";
    })
    # iconv: try to fix MacOS build
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/0f399a86dac9ff1a2d57a107264d749179bb2d05.patch";
      hash = "sha256-lzYBBbCgTuWm1g2gGrbyn6PisHk/yBSIXOmknwTHosU=";
    })
  ];
  patchFlags = [ "-p1" "-d modules" ];

  postPatch = ''
    substituteInPlace modules/get_deps \
      --replace "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    substituteInPlace modules/mapview/mapview.cpp \
      --replace "/usr/share" "$out/share"
    patchShebangs .

    substituteInPlace vmap_data/scripts/vmaps_preview --replace "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_out --replace "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_get_fig --replace "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps_in --replace "vmaps.sh" "$out/bin/vmaps.sh"
    substituteInPlace vmap_data/scripts/vmaps.sh --replace "/usr" "$out"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ms2view";
      exec = "ms2view";
      comment = "Viewer for geodata and raster maps";
      desktopName = "ms2view";
      genericName = "Mapsoft2 viewer";
      categories = [ "Geography" "Geoscience" "Science" ];
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

  preBuild = "export SKIP_IMG_DIFFS=1";

  makeFlags = [ "prefix=$(out)" ];

  dontWrapGApps = true;

  postFixup = ''
    for f in $out/bin/ms2*; do
      wrapGApp $f
    done
  '';

  meta = with lib; {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = true;
  };
})
