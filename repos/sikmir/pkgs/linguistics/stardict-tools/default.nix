{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, libtool
, pkg-config
, gtk3
, libmysqlclient
, libxml2
, pcre
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardict-tools";
  version = "2021-04-05";

  src = fetchFromGitHub {
    owner = "huzheng001";
    repo = "stardict-3";
    rev = "e861c2a8f551a37f3ce1520d5cdcd611f146d90d";
    hash = "sha256-k3rvl6Y2zMXTQ+VQIydUgKk3f8Ji0gP8IJFDWWlOeyY=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];
  buildInputs = [
    gtk3
    libmysqlclient
    libxml2
    pcre
  ];

  hardeningDisable = [ "format" ];

  postPatch = ''
    substituteInPlace tools/src/wikipediaImage.cpp \
      --replace "MYSQL_PORT" "0"
    substituteInPlace tools/src/Makefile.am \
      --replace "noinst_PROGRAMS =" "bin_PROGRAMS ="
  '';

  preConfigure = "./autogen.sh";
  configureFlags = [ "--disable-dict" ];

  postInstall = ''
    find $out/bin/ -not -name 'stardict-*' -type f | \
      sed 'p;s#bin/#bin/stardict-#' | \
      xargs -n2 mv
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Stardict tools";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
})
