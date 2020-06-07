{ fetchgit, stdenv, ncurses, ncurses5, portmidi }:

stdenv.mkDerivation {
  pname = "orca";
  version = "git";
  src = fetchgit (builtins.fromJSON (builtins.readFile ./source.json));
  buildInputs = [ ncurses ncurses5 portmidi ];
  buildPhase = ''
    bash ./tool build --portmidi --mouse --pie --harden orca
  '';
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ./build/orca $out/bin/orca
  '';
}
