{ lib
, stdenv
, fetchFromGitHub
, perlPackages
, python2Packages
, gimp
, bc
, fig2dev
, imagemagick
, m4
, netpbm
, pkg-config
, scons
, boost
, curl
, giflib
, gtkmm2
, jansson
, libjpeg
, libpng
, libshell
, libtiff
, libusb1
, libxml2
, libyaml
, libzip
, proj
, shapelib
, zlib
, getopt
}:

stdenv.mkDerivation rec {
  pname = "mapsoft";
  version = "2021-01-31";

  src = fetchFromGitHub {
    owner = "ushakov";
    repo = pname;
    rev = "45fdd650f1fb1d30ac0682550c541bc7a3d368fc";
    hash = "sha256-s/9en0d8eYsbDb3krZrmenFaZd9LPuNG0uEo35K0oNo=";
  };

  patches = [ ./0001-fix-build.patch ];

  postPatch = ''
    substituteInPlace scripts/map_rescale \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
    substituteInPlace core/vmap/vmap_ocad.cpp \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
    substituteInPlace core/vmap/zn.cpp \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
  '';

  nativeBuildInputs = [
    fig2dev
    imagemagick
    m4
    netpbm
    perlPackages.perl
    pkg-config
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
  propagatedBuildInputs = [ bc libshell ];

  preBuild = ''
    export CPPFLAGS="-I${boost.dev}/include -I${giflib}/include"
    export LINKFLAGS="-L${giflib}/lib -lgif"
  '';

  sconsFlags = [ "minimal=1" "prefix=$(out)" ];

  postInstall = ''
    wrapPythonProgramsIn $out/lib/gimp/${lib.versions.major gimp.version}.0/plug-ins/
    substituteInPlace $out/bin/mapsoft_wp_parse \
      --replace "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
    wrapProgram $out/bin/mapsoft_wp_parse --prefix PERL5LIB : "$PERL5LIB"
    substituteInPlace $out/bin/map_rescale \
      --replace "getopt " "${getopt}/bin/getopt "
  '';

  meta = with lib; {
    description = "Mapping software for linux";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
