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
let
  pname = "stardict-tools";
  date = stdenv.lib.substring 0 10 sources.stardict-3.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
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

  NIX_CFLAGS_COMPILE = [ "-std=c++03" ];

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
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
