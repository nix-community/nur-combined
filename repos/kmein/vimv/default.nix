{ stdenv, bash, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "vimv";
  src = fetchFromGitHub {
    owner = "thameera";
    repo = "vimv";
    rev = "4152496c1946f68a13c648fb7e583ef23dac4eb8";
    sha256 = "1fsrfx2gs6bqx7wk7pgcji2i2x4alqpsi66aif4kqvnpqfhcfzjd";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    sed 's:#!/bin/bash:#!${bash}/bin/bash:' $src/vimv > $out/bin/vimv
    chmod 755 $out/bin/vimv
  '';
  meta = with stdenv.lib; {
    homepage = https://github.com/thameera/vimv;
    description = "Batch-rename files using Vim";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
