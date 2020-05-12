{ fetchgit, stdenv, ncurses, ncurses5, portmidi }:

let
  orcaSrc = fetchgit {
    url = "https://git.sr.ht/~rabbits/orca";
    rev = "105371b868f6acd36da4a86e1a8dfd1fc2c9bf25";
    sha256 = "02s93j55akxw5lwikwwzblw58g9v6zbrw4bdwdbx1743w87m28l5";
  };

in stdenv.mkDerivation {
  pname = "orca";
  version = "git";
  src = orcaSrc;
  buildInputs = [ ncurses ncurses5 portmidi ];
  buildPhase = ''
    bash ./tool build --portmidi --mouse --pie --harden orca
  '';
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ./build/orca $out/bin/orca
  '';
}
