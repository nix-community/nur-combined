{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  gnome-common,
  libtool,
  p7zip,
  pkg-config,
  gtk2,
  libmysqlclient,
  libxml2,
  pcre2,
  which,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardict-tools";
  version = "3.0.7-2";

  __structuredAttrs = true;

  src = fetchurl {
    url = "mirror://sourceforge/stardict-4/stardict-${finalAttrs.version}-src.7z";
    hash = "sha256-U9Wfyz0eV3kw7k7XlvBEuHXPrqo+rdhP7fvviSYfyQc=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gnome-common
    libtool
    p7zip
    pkg-config
    which
    yelp-tools
  ];

  buildInputs = [
    gtk2
    libmysqlclient
    libxml2
    pcre2
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
