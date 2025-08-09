{
  lib,
  stdenv,
  fetchsvn,
  autoconf,
  automake,
  libtool,
}:

stdenv.mkDerivation {
  pname = "libgarmin";
  version = "0-unstable-2008-12-27";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/libgarmin/svn/libgarmin/dev";
    rev = "320";
    sha256 = "sha256-aFXD+HnEZBsg2kcc8m8v95poz87DrwgZl4diHSeQZ78=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    aclocal \
    && autoheader \
    && automake --add-missing \
    && autoreconf
  '';

  meta = {
    description = "Garmin IMG format library";
    homepage = "http://libgarmin.sourceforge.net/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
