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
  version = "20220624-alt1";

  src = fetchFromGitHub {
    owner = "ushakov";
    repo = "mapsoft";
    rev = "e51645da7bbb7f6ca6505dd6e6f9a009556a78c1";
    hash = "sha256-GPlLVMWqYXs0K3UzQnYlWPm0t9qz6rzQmW1dTOUtPDY=";
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
    export CPPFLAGS="-I${boost.dev}/include -I${giflib}/include -I${proj.dev}/include"
    export LINKFLAGS="-L${giflib}/lib -lgif -L${proj}/lib -lproj"
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
    skip.ci = true;
  };
}
