{ stdenv, fetchurl, ncurses }:

stdenv.mkDerivation rec {
  name = "cboard-0.7.5";

  src = fetchurl {
    url = "https://liquidtelecom.dl.sourceforge.net/project/c-board/0.7.5/cboard-0.7.5.tar.bz2";
    sha256 = "18561laya4pm3s23lvp12qdlwlj18y0wsxrmazhm65jkycwq0x6x";
  };

  buildInputs = [ ncurses ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "CBoard is a Console/Curses PGN file browser, editor and interface to chess engines supporting the XBoard protocol. It supports SAN move format with annotations and lots more.";
    homepage = "https://gitlab.com/bjk/cboard";
    license = with licenses; [ gpl2 ];
    platforms = platforms.linux;
  };
}
