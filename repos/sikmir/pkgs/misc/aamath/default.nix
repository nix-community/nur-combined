{ lib, stdenv, fetchwebarchive, fetchpatch, readline, ncurses, bison, flex }:

stdenv.mkDerivation rec {
  pname = "aamath";
  version = "0.3";

  src = fetchwebarchive {
    url = "http://fuse.superglue.se/aamath/aamath-${version}.tar.gz";
    timestamp = "20190303013301";
    sha256 = "0cdnfy7zdwyxvkhnk5gdcl75w9ag3n95i3sxrrawvqlmhrcg8hwq";
  };

  patches = (fetchpatch {
    url = "https://raw.githubusercontent.com/macports/macports-ports/6c3088afddcf34ca2bcc5c209f85f264dcf0bc69/math/aamath/files/patch-expr.h.diff";
    sha256 = "0ls6xpjhldrivfbva2529i6maid44w33by38g80wzzvas2lxrli6";
  });

  patchFlags = [ "-p0" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "lex " "flex " \
      --replace "-ltermcap" "-lncurses"
  '';

  nativeBuildInputs = [ bison flex ];

  buildInputs = [ readline ncurses ];

  installPhase = ''
    install -Dm755 aamath -t $out/bin
    install -Dm644 aamath.1 -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "ASCII art mathematics";
    homepage = "http://fuse.superglue.se/aamath/";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
