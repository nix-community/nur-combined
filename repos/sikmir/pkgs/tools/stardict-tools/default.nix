{ stdenv, autoconf, automake, libtool, pkg-config,
  gtk3, libmysqlclient, libxml2, pcre, stardict-3 }:

stdenv.mkDerivation rec {
  pname = "stardict-tools";
  version = stdenv.lib.substring 0 7 src.rev;
  src = stardict-3;

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

  NIX_CFLAGS_COMPILE = [ "-Wno-error=format-security" ];

  postPatch = ''
    substituteInPlace tools/src/wikipediaImage.cpp \
      --replace "MYSQL_PORT" "0"
    substituteInPlace tools/src/Makefile.am \
      --replace "noinst_PROGRAMS =" "bin_PROGRAMS ="
  '';

  preConfigure = ''./autogen.sh'';
  configureFlags = [ "--disable-dict" ];

  postInstall = ''
    find $out/bin/ -not -name 'stardict-*' -type f | \
      sed 'p;s#bin/#bin/stardict-#' | \
      xargs -n2 mv
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = stardict-3.description;
    homepage = stardict-3.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
