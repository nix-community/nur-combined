{ stdenv
, autoconf
, automake
, libtool
, pkg-config
, gtk3
, libmysqlclient
, libxml2
, pcre
, sources
}:

stdenv.mkDerivation {
  pname = "stardict-tools";
  version = stdenv.lib.substring 0 10 sources.stardict-3.date;

  src = sources.stardict-3;

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

  meta = with stdenv.lib; {
    inherit (sources.stardict-3) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
