{ lib
, stdenv
, fetchFromGitHub
, substituteAll
, db
, giflib
, gsettings-desktop-schemas
, gtkmm3
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

stdenv.mkDerivation rec {
  pname = "mapsoft2";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = pname;
    rev = "${version}-alt1";
    sha256 = "sha256-wOxJdDl7y7iE6kKlfBNkknh68EJksjcKt6DFqkEdiIQ=";
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

    # https://github.com/OSGeo/PROJ/pull/2547
    cat > modules/pc/proj.pc << EOF
    Name: PROJ
    Description: Coordinate transformation software library
    Requires:
    Version: ${proj.version}
    Libs: -lproj
    EOF
  '';

  nativeBuildInputs = [
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

  meta = with lib; {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
}
