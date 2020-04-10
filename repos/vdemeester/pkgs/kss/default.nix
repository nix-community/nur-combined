{ stdenv, lib, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "kss-git";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "kss";
    rev = "6d950ead30f2b12b0e4e55530326b8d3b91e999c";
    sha256 = "1cvq4hm151j0lk2hrxxa11qqa6fidmmvplqrs5kfsfwfljsz339j";
  };
  buildInputs = [ python3 ];
  installPhase = ''
    substituteInPlace kss --replace \
        "fileout.write(('#!/usr/bin/env %s\n' % env).encode('utf-8'))" \
        "fileout.write(('#!%s/bin/%s\n' % (os.environ['python3'], env)).encode('utf-8'))"
    mkdir -p $out/bin
    cp kss $out/bin
    # completions
    mkdir -p $out/share/zsh/site-functions
    cp _kss $out/share/zsh/site-functions/
  '';
}
