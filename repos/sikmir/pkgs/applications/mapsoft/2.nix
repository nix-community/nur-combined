{ stdenv, fetchFromGitHub, db, giflib, gsettings-desktop-schemas
, gtkmm3, jansson, libjpeg, libpng, libtiff, libxml2, libzip
, perlPackages, pkgconfig, proj, shapelib, unzip }:

stdenv.mkDerivation rec {
  pname = "mapsoft2";
  version = "2020-02-27";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = pname;
    rev = "048befdc24252c798d3c2339a34a25e8faa7c6f1";
    sha256 = "05fbcrikcnaydzl53m8gl42z8qgqyrn78ir95h76pkl2vkfdscyh";
    fetchSubmodules = true;
  };

  patches = [ ./0002-fix-build.patch ];

  postPatch = ''
    substituteInPlace modules/get_deps \
      --replace "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    substituteInPlace modules/pc/libgif.pc \
      --replace "@giflib@" "${giflib}"
    substituteInPlace modules/pc/libdb.pc \
      --replace "@db@" "${db.dev}"
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
    libjpeg
    libpng
    libtiff
    libxml2
    libzip
    proj
    shapelib
  ];

  dontConfigure = true;

  makeFlags = [ "prefix=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
