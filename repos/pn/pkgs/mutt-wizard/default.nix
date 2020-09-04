{ stdenv, fetchgit, pkgconfig, isync, pass, neomutt, msmtp }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "mutt-wizard";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/mutt-wizard";
    rev = "289533279b21f0fc6ecbdf03ebde2a67741e3ded";
    sha256 = "1bb9429wabv85zja2y89vhj15qcd10acbg5k6ylilw067wzs9ks5";
  };

  nativeBuildInputs = [ pkgconfig ];

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
