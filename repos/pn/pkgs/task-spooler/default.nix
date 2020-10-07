{ stdenv, fetchurl }:
with stdenv.lib;

let
  pname = "task-spooler";
  version = "1.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "http://vicerveza.homeunix.net/~viric/soft/ts/ts-${version}.tar.gz";
      sha256 = "15dkzczx10fhl0zs9bmcgkxfbwq2znc7bpscljm4rchbzx7y6lsg";
    };

    installPhase = ''
      mkdir -p $out/bin $out/share/man/man1 $out/share/doc/task-spooler
      cp ts $out/bin/tsp
      cp ts.1 $out/share/man/man1/tsp.1
      cp TRICKS $out/share/doc/task-spooler/TRICKS
    '';

    meta = {
      homepage = "http://vicerveza.homeunix.net/~viric/soft/ts/";
      description = "Queue up tasks from the shell for batch execution";
      license = licenses.gpl3;
    };
  }
