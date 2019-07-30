{ stdenv, fetchurl, ncurses, cairo } :

stdenv.mkDerivation {
  name = "nudoku";
  version = "1.0.0";
  src = fetchurl {
    url = https://github.com/jubalh/nudoku/releases/download/1.0.0/nudoku-1.0.0.tar.xz;
    sha256 = "0nr2j2z07nxk70s8xnmmpzccxicf7kn5mbwby2kg6aq8paarjm8k";
  };

  buildInputs = [ ncurses cairo ];

  installPhase = ''
    mkdir -p $out/bin
    make
    mv ./src/nudoku $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/jubalh/nudoku";
    description = "ncurses based sudoku game";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
