{ lib, stdenv, fetchgit, udev, git }:

let
  pname = "keyd";
  version = "1.1.2";
in stdenv.mkDerivation rec {
  inherit version pname;

  src = fetchgit {
    url = "https://github.com/rvaiya/keyd.git";
    rev = "c7ee83350dc0064e9f03a780995efce18266ea4d";
    sha256 = "sha256-lwEO0SWbsshSY2/M39fay5OlJgRBScIj6Tt7zz0U63s=";
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
