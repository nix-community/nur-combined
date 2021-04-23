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

stdenv.mkDerivation rec {
  pname = "stardict-tools";
  version = "2021-01-07";

  src = fetchFromGitHub {
    owner = "huzheng001";
    repo = "stardict-3";
    rev = "36347a29526e4bacea910017efa1d839dab89667";
    sha256 = "1qvf74j4m7s3cjhrwdfgji436im0zxh0m1j92ybdk0krnnv29c4m";
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
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
