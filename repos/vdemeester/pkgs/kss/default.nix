{ stdenv, lib, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "kss";
  version = "0.0.2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "kss";
    rev = "${version}";
    sha256 = "1akjval7f17ij0fwyghspp2p27agkls82nafynfaxiakmxwmr7lr";
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
