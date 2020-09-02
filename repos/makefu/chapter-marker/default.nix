{ coreutils, fetchFromGitHub, makeWrapper, xclip, libnotify, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "chapter-marker-${version}";
  version = "master";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "chapter-marker";
    rev = "71b9bb8bc4d6fa87de6bea8f42d5486d05cf5443";
    sha256 = "13cvk24pwwyv9i21h57690s5niwkcrcvn8l24zfxwbgq0wwzw38x";
  };

  buildInputs = [ makeWrapper ];

  installPhase =
    let
      path = stdenv.lib.makeBinPath [
        coreutils
        libnotify
        xclip
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
