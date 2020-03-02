{ stdenv, fetchFromGitHub, db, giflib, gsettings-desktop-schemas
, gtkmm3, jansson, libjpeg, libpng, libtiff, libxml2, libzip
, perlPackages, pkgconfig, proj, shapelib, unzip }:

stdenv.mkDerivation rec {
  pname = "mapsoft2";
  version = "2020-03-02";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = pname;
    rev = "3c4e27fc6c48be158656f31cf9cbb32cd5246ab3";
    sha256 = "1fb4r7nqj5z40s2pzl0i3p1gxcwxs3cca83i95a78n8gvjwkv9vm";
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

  preBuild = "export SKIP_IMG_DIFFS=1";

  makeFlags = [ "prefix=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
