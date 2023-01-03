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
  version = "2.0";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = "${finalAttrs.version}-alt1";
    hash = "sha256-cZHxCqfAY0DT3Zr3AdY3BMtzsiC9yXA2CUD/uM27SRE=";
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
