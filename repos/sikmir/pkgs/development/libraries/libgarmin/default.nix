{ stdenv, fetchsvn, autoconf, automake, libtool }:

stdenv.mkDerivation {
  pname = "libgarmin";
  version = "2008-12-27";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/libgarmin/svn/libgarmin/dev";
    rev = "320";
    sha256 = "1gv7j0kisql7jwchiby3rv7ni6pp5xpz4727v8h1nr64g7wc6mb8";
  };

  nativeBuildInputs = [ autoconf automake libtool ];

  preConfigure = ''
    aclocal \
    && autoheader \
    && automake --add-missing \
    && autoreconf
  '';

  meta = with stdenv.lib; {
    description = "Garmin IMG format library";
    homepage = "http://libgarmin.sourceforge.net/";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
