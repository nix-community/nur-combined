{ stdenv
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
, pkgconfig
, proj
, shapelib
, unzip
}:

stdenv.mkDerivation {
  pname = "mapsoft2";
  version = "unstable-2020-06-22";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = "3966f2bcb48fdb3a6b17af82dcd89276ee38f6d9";
    sha256 = "0fk41wvpv7z99j0s7lh4aja8gn1wfm8qnmdwjh4592iz0009pjh3";
    fetchSubmodules = true;
  };

  patches = [
    (
      substituteAll {
        src = ./0002-fix-build.patch;
        db = db.dev;
        giflib = giflib;
      }
    )
  ];

  postPatch = ''
    substituteInPlace modules/get_deps \
      --replace "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    substituteInPlace modules/mapview/mapview.cpp \
      --replace "/usr/share" "${placeholder "out"}/share"
    patchShebangs .
  '';

  nativeBuildInputs = [
    perlPackages.perl
    pkgconfig
    unzip
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

  dontConfigure = true;

  preBuild = "export SKIP_IMG_DIFFS=1";

  makeFlags = [ "prefix=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
