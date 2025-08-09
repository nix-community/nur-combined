{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  libtool,
  p7zip,
  pkg-config,
  gtk2,
  libmysqlclient,
  libxml2,
  pcre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardict-tools";
  version = "3.0.6.2";

  src = fetchurl {
    url = "mirror://sourceforge/stardict-4/stardict-${finalAttrs.version}-2-src.7z";
    hash = "sha256-1XLfXs5v2ZvP5xqCN4x1+0BvkIGc8cHWrgiP0b0DP0U=";
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
  configureFlags = [ (lib.enableFeature false "dict") ];

  env.NIX_CFLAGS_COMPILE = "-std=c++14";

  postInstall = ''
    find $out/bin/ -not -name 'stardict-*' -type f | \
      sed 'p;s#bin/#bin/stardict-#' | \
      xargs -n2 mv
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Stardict tools";
    homepage = "https://stardict-4.sourceforge.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true; # configure.ac:91: error: possibly undefined macro: AM_ICONV
  };
})
