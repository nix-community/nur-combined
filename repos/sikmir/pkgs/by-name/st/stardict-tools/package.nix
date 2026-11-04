{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  gettext,
  libtool,
  p7zip,
  pkg-config,
  expat,
  gtk3,
  libmysqlclient,
  libxml2,
  pcre2,
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
    gettext
    libtool
    p7zip
    pkg-config
  ];

  buildInputs = [
    expat
    gtk3
    libmysqlclient
    libxml2
    pcre2
  ];

  hardeningDisable = [ "format" ];

  postPatch = ''
    # dict is disabled, don't bootstrap it (requires intltool)
    sed -i '/dict\/autogen.sh/d' autogen.sh
    substituteInPlace tools/configure.ac \
      --replace-fail "PKG_CHECK_MODULES(DSL2DICT, libpcre)" "PKG_CHECK_MODULES(DSL2DICT, libpcre2-8)"
    substituteInPlace tools/src/Makefile.am \
      --replace-fail "noinst_PROGRAMS =" "bin_PROGRAMS ="
  '';

  preConfigure = ''
    # AM_ICONV
    export ACLOCAL_PATH="${gettext}/share/gettext/m4''${ACLOCAL_PATH:+:}''${ACLOCAL_PATH-}"
    ./autogen.sh
  '';
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
  };
})
