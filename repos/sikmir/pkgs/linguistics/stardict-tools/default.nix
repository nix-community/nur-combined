{ lib
, stdenv
, fetchurl
, autoconf
, automake
, libtool
, p7zip
, pkg-config
, gtk2
, libmysqlclient
, libxml2
, pcre
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardict-tools";
  version = "3.0.6";

  src = fetchurl {
    url = "mirror://sourceforge/stardict-4/stardict-${finalAttrs.version}-2-src.7z";
    hash = "sha256-2Q+PNqFCnxioFmD4IEUQlD2x22Ueh+nKXP5i9N3STFE=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    p7zip
    pkg-config
  ];

  buildInputs = [
    gtk2
    libmysqlclient
    libxml2
    pcre
  ];

  hardeningDisable = [ "format" ];

  postPatch = ''
    substituteInPlace tools/src/Makefile.am \
      --replace-fail "noinst_PROGRAMS =" "bin_PROGRAMS ="
  '';

  preConfigure = "./autogen.sh";
  configureFlags = [
    (lib.enableFeature false "dict")
  ];

  env.NIX_CFLAGS_COMPILE = "-std=c++14";

  postInstall = ''
    find $out/bin/ -not -name 'stardict-*' -type f | \
      sed 'p;s#bin/#bin/stardict-#' | \
      xargs -n2 mv
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Stardict tools";
    homepage = "https://stardict-4.sourceforge.net/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
})
