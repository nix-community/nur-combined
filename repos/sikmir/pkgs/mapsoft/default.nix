{ stdenv, perlPackages, python2Packages, gimp, mapsoft
, fig2dev, imagemagick, m4, netpbm, pkgconfig, scons
, boost, curl, giflib, gtkmm2, jansson, libjpeg, libpng
, libtiff, libusb1, libxml2, libyaml, libzip
, proj, shapelib, zlib }:

stdenv.mkDerivation rec {
  pname = "mapsoft";
  version = stdenv.lib.substring 0 7 src.rev;
  src = mapsoft;

  patches = [ ./0001-fix-build.patch ];

  postPatch = ''
    substituteInPlace scripts/map_rescale \
      --replace "/usr/share/mapsoft" "${mapsoft}/share/mapsoft"
    substituteInPlace core/vmap/vmap_ocad.cpp \
      --replace "/usr/share/mapsoft" "${mapsoft}/share/mapsoft"
    substituteInPlace core/vmap/zn.cpp \
      --replace "/usr/share/mapsoft" "${mapsoft}/share/mapsoft"
  '';

  nativeBuildInputs = [
    fig2dev
    imagemagick
    m4
    netpbm
    perlPackages.perl
    pkgconfig
    python2Packages.wrapPython
    scons
  ];
  buildInputs = [
    boost
    curl
    giflib
    gtkmm2
    jansson
    libjpeg
    libpng
    libtiff
    libusb1
    libxml2
    libyaml
    libzip
    perlPackages.TextIconv
    proj
    shapelib
    zlib
  ];

  preBuild = ''
    export CPPFLAGS="-I${boost.dev}/include -I${giflib}/include"
    export LINKFLAGS="-L${giflib}/lib -lgif"
  '';

  sconsFlags = [ "minimal=1" "prefix=${placeholder "out"}" ];

  postInstall = ''
    wrapPythonProgramsIn $out/lib/gimp/${stdenv.lib.versions.major gimp.version}.0/plug-ins/
    substituteInPlace $out/bin/mapsoft_wp_parse \
      --replace "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    wrapProgram $out/bin/mapsoft_wp_parse --prefix PERL5LIB : "$PERL5LIB"
  '';

  meta = with stdenv.lib; {
    description = mapsoft.description;
    homepage = mapsoft.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
