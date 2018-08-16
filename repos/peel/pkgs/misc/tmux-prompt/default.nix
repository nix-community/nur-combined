{ stdenv, coreutils, bash, tmux, makeWrapper }:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "1.0.0";
  baseName = "tmux-prompt";
  name = "${baseName}-${version}";

  buildInputs = [ coreutils bash tmux makeWrapper ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${./bin}/* $out/bin/
    wrapProgram $out/bin/tmux-prompt --prefix PATH : "${wrapperPath}"
  '';

  wrapperPath = with stdenv.lib; makeBinPath ([
    coreutils
    bash
    tmux
  ]);

  meta = with stdenv.lib; {
    description = "My tmux-prompt";
    platforms = platforms.unix;
    license = licenses.gpl3;
  };
}
