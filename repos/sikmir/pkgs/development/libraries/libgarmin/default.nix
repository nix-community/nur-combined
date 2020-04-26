{ stdenv, fetchsvn, autoconf, automake, libtool }:

stdenv.mkDerivation rec {
  pname = "libgarmin";
  version = "2008-12-27";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/libgarmin/svn/libgarmin/dev";
    rev = "320";
    sha256 = "sha256-aFXD+HnEZBsg2kcc8m8v95poz87DrwgZl4diHSeQZ78=";
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
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
