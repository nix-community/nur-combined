{ pkgs, stdenv, lib, fetchFromGitHub }:


stdenv.mkDerivation rec {
  name = "logstash-input-rss-${version}";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "logstash-plugins";
    repo = "logstash-input-rss";
    rev = "v${version}";
    sha256 = "026902g256385dx3qkbknz10vsp9dm2ymjdx6s6rkh3krs67w09l";
  };

  dontBuild    = true;
  dontPatchELF = true;
  dontStrip    = true;
  dontPatchShebangs = true;
  installPhase = ''
    mkdir -p $out/logstash
    cp -r lib/* $out/
  '';

  meta = with lib; {
    description = "logstash output plugin";
    homepage    = https://github.com/logstash-plugins/logstash-input-rss;
    license     = stdenv.lib.licenses.asl20;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with maintainers; [ makefu ];
  };
}
