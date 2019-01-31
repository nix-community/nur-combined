{ stdenv, ncurses }:
stdenv.mkDerivation {
  name = "xterm-24bit-terminfo";
  nativeBuildInputs = [ ncurses ];
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/terminfo
    tic -x -o $out/share/terminfo xterm-24bit.terminfo
  '';
}

