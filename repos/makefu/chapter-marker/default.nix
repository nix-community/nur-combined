{ coreutils, fetchFromGitHub, makeWrapper, xdotool, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "chapter-marker-${version}";
  version = "master";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "chapter-marker";
    rev = "7602b611fb3d67fdb8a86db23220074dfa9dfa1e";
    sha256 = "0cwh650c3qhdrcvrqfzgrwpsnj4lbq64fw2sfwvnbxz94b4q36av";
  };

  buildInputs = [ makeWrapper ];

  installPhase =
    let
      path = stdenv.lib.makeBinPath [
        coreutils
        xdotool
      ];
    in
    ''
      mkdir -p $out/bin
      cp chapter-mark chapter-start $out/bin/
      wrapProgram $out/bin/chapter-mark \
        --prefix PATH : ${path}
      wrapProgram $out/bin/chapter-start \
        --prefix PATH : ${path}
    '';
}
