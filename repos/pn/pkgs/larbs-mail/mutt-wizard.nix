{ stdenv, fetchgit }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "mutt-wizard";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/mutt-wizard";
    rev = "289533279b21f0fc6ecbdf03ebde2a67741e3ded";
    sha256 = "1bb9429wabv85zja2y89vhj15qcd10acbg5k6ylilw067wzs9ks5";
  };

  buildPhase = ''
    sed -i 's/(PREFIX)/(out)/g' Makefile
    sed -i 's:mwconfig="\$muttshare/mutt-wizard.muttrc":mwconfig=/etc/neomuttrc:' bin/mw
    make PREFIX=$out SHELL=$SHELL install
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "A script for automatically configuring mutt";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
