{ lib, stdenv, fetchgit, udev, git }:

let
  pname = "keyd";
  version = "1.3.1";
in stdenv.mkDerivation rec {
  inherit version pname;

  src = fetchgit {
    url = "https://github.com/rvaiya/keyd.git";
    rev = "f7e1c7dfcbfb1076b4c53c374e410e354b6a4576";
    sha256 = "sha256-TaxG0Rw434q/qPwuTG19Hy6bEkL2URxuH93IJwDP1yA=";
  };

  buildInputs = [ git udev ];

  patches = [ ./keyd.patch ];

  buildPhase = ''
    make VERBOSE=1 LOCK_FILE=/tmp/keyd.lock LOG_FILE=/tmp/keyd.log
  '';

  installPhase = ''
    make install DESTDIR=$out PREFIX=
  '';

  meta = {
    description = "A key remapping daemon for linux.";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
