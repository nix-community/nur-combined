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
  version = "2021-06-07";

  src = fetchFromGitHub {
    owner = "ushakov";
    repo = pname;
    rev = "9f6bfff9ab82fc3dafa370c99b1bbbd9c025b6cf";
    hash = "sha256-E5HMNeo3JXOZZgIjVIS/TbNY6f08Z4dt66zPKvBN26U=";
  };

  patches = [ ./0001-fix-build.patch ];

  postPatch = ''
    substituteInPlace scripts/map_rescale \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
    substituteInPlace core/vmap/vmap_ocad.cpp \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
    substituteInPlace core/vmap/zn.cpp \
      --replace "/usr/share/mapsoft" "$out/share/mapsoft"
    substituteInPlace vector/SConscript \
      --replace "vmap4" ""
    substituteInPlace programs/SConscript \
      --replace "convs_gtiles" ""
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
