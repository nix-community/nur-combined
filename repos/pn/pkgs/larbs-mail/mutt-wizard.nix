{ stdenv, fetchgit }:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "mutt-wizard";
  version = "3.0";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/mutt-wizard";
    rev = "ad5ca516439adce1e9be4eb50f8bbb1dc7bfcc03";
    sha256 = "0g9r8rcvlr4z6ynm2dqgj87fgqaivxvwncch26nqbv3fix9c3yr3";
  };

  buildPhase = ''
    sed -i 's/(PREFIX)/(out)/g' Makefile
    sed -i '/mwconfig=/d' bin/mw
    sed -i '/mwconfig\ \$MARKER/d' bin/mw
    make PREFIX=$out SHELL=$SHELL install
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "A script for automatically configuring mutt";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
