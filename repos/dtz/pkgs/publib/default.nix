{ stdenv,  fetchurl }:

stdenv.mkDerivation rec {
  name  = "publib-${version}";
  version = "0.40";

  src = fetchurl {
    url = http://ftp.debian.org/debian/pool/main/p/publib/publib_0.40.orig.tar.gz;
    sha256 = "1fcq0j78mqp7wjz8gilk3bxsa60dj0sbmgl5nm5ljni6h837vv1m";
  };

  # From debian
  patches = [
    ./0001-Remove-strndup.patch
    ./0002-Fix-undefined-behavior-warning.patch
    ./0003-Remove-Makefile-at-distclean.patch
    ./0004-Fix-spelling-errors-in-manpages.patch
    ./0005-Pass-LDFLAGS-to-test-programs.patch
  ];

  meta = with stdenv.lib; {
    description = "Heterogenous library for the C programming language";
    homepage = https://code.google.com/archive/p/publib;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
