{ lib
, stdenv
, fetchFromGitHub
, substituteAll
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

  patches = (substituteAll {
    src = ./0002-fix-build.patch;
    db = db.dev;
    giflib = giflib;
  });

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

    # https://github.com/slazav/mapsoft2-libs/commit/9300f93e171769bbf8710d9dfa5f2724b7b6142d
    substituteInPlace modules/geo_data/conv_geo.test.cpp \
      --replace "PROJ_AT_LEAST_VERSION(9, 2, 1)" "PROJ_AT_LEAST_VERSION(9, 2, 0)"
  '';

  nativeBuildInputs = [
    fig2dev
    imagemagick
    perlPackages.perl
    pkg-config
    unzip
    wrapGAppsHook
  ];

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
    platforms = platforms.linux;
    skip.ci = true;
  };
})
