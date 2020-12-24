{ stdenv, newScope, lib, makeWrapper, fetchgit, coreutils, gawk, gnugrep, gnused, xrandr, help2man }:

# TODO cleanup

with lib;
let
  callPackage = newScope self;
  self = {
    libshlist = callPackage ./libshlist.nix { };
  };
  dependencies = [
    coreutils
    gawk
    gnugrep
    gnused
    xrandr
  ];
in
with self;

stdenv.mkDerivation rec {
  pname = "mons";
  version = "0c9e1a1dddff23a0525ed8e4ec9af8f9dd8cad4c";

  src = fetchgit {
    url = "https://github.com/Ventto/${pname}.git";
    rev = "${version}";
    sha256 = "0cwbdyma7ylvy3m8jmldd26f3m0adgjdz6vs300mrgqmyqpvddxs";
    fetchSubmodules = false;
  };

  patchPhase = ''
    cp ${libshlist}/lib/liblist.sh ./libshlist/
    patchShebangs ./libshlist/liblist.sh

    substituteInPlace ./Makefile --replace "/usr" ""
  '';

  dontBuild = true;

  installFlags = [ "DESTDIR=$(out)" ];

  nativeBuildInputs = [ makeWrapper help2man ];

  postInstall = ''
    wrapProgram "$out/bin/mons" --set PATH ${makeBinPath dependencies}
  '';

  meta = with stdenv.lib; {
    description = "mons";
    homepage = "https://github.com/Ventto/mons";
    license = licenses.mit;
    maintainers = with maintainers; [ jk ];
    platforms = platforms.unix;
  };
}
